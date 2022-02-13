# Pipelines and their quirks

Pipelines are an amazing feature of bash. I use them all the time. And I noticed a lot of situations when the shell code abuses the pipelines. It’s this abuse that’s bothering me so much that I decided to write a post exclusively about how to use pipelines properly.

## What are pipelines?

A pipeline connects the standard output of a command to the standard input of the next. Assuming you want to print out the names of all users with a `/bin/bash` shell, a way of achieving this is:
```
grep /bin/bash /etc/passwd | cut -d: -f1
```
The `|` character signifies where the first command ends, and the next command begins. So the first command, `grep`, writes to its standard output all the lines that contain `/bin/bash`. The `cut` command receives that text at its standard input. Furthermore, it displays the first field, which is the username.

## More pipes equal less performance

You can extend the command and include as many pipes as you want. However, you have to know that each pipe means that the shell executes another process in parallel. So the more pipes you have, the more processes will run at the same time on your machine. This might not seem like a problem, but when you’re running some QA performance testing script or a monitoring script, you might want to reduce the impact your scripts have, to the minimum.

By far the most used commands in pipelines are `cat` followed by `grep`. First and foremost, `cat` is not needed because running:
```
cat file | grep pattern
```
is equivalent to:
```
grep pattern file
```
or:
```
grep pattern <file
```
both of which only run a single execution and not two.

So you see that `grep` accepts a file as an argument. Moreover, it’s the case for many if not most commands. Try to run it with `--help` and check if it accepts a file as an argument and use that instead of a pipe starting with `cat`.

You can reduce the number of `grep` calls using its own `-e` or `-E` arguments. Instead of using:
```
command | grep pattern1 | grep pattern2 | grep pattern3
```
you can use:
```
command | grep -e pattern1 -e pattern2 -e pattern3
```

Alternatively, for more complex patterns, you can use regular expressions to filter lines via `-E`:
```
command | grep -E "pattern1|pattern2|pattern3"
```
Of course, other commands might accept similar arguments.

## Write optimised pipelines

When you’re running commands on a machine that’s already having a high load average, you need to keep the executions to the minimum, especially in the business environment, and here’s why:

* if the machine runs customer applications, those applications are negatively impacted if you generate even more load with your commands
* when your monitoring application (like Nagios or Sensu) is running a bunch of commands once every minute or even less, and they aren’t optimised, they can do more bad than good
* in case the OS is already loaded, the executables that are part of your pipeline are no longer cached or are swapped to the disk, so the retrieval of those caches becomes expensive
* during the run of a performance/benchmarking testing suite, the fingerprint of your commands have to be kept at a minimum to get the best out of that test – and that’s what you’re aiming for in general

The above list can go on and on. I’ve seen with my own eyes people kneeling machines because of running some silly long pipelines to investigate and try to fix the load, and it only ended up with a machine reboot, which impacted the customers. You just can’t afford to play with these things in a business environment.

I talked a lot about business, and you might think that scripts that run at home are okay to be looser with following the rules. However, getting in the habit of writing sloppy commands is going to come back and bite your arse whenever you want to use your skills in a business environment. Whether you are consulting, an employee, or running your startup, don’t plan for failure.

## Time and resources consumed

As I have previously written, adding the time keyword at the beginning of a pipeline, with the optional argument of `-p` (for POSIX mode), can determine bash to display some metrics for the entire pipeline.

The `TIMEFORMAT` variable can also determine which resources to display and how. You can read my entire post about time for more details.

## What about the standard error?

By default, _stderr_ (short for _Standard Error_) content is not transmitted through the pipeline, which means that the terminal displays it freely, so the following pipeline displays:
```
$ ls /etc /non-existent | grep passwd
ls: cannot access '/non-existent': No such file or directory
passwd
passwd-
```
The first line containing `No such file or directory` is written by the `ls` command at standard error. It’s not filtered by `grep` because this is not the default behaviour. If you thought that adding a `2>&1` redirection fixes it, consider the `|&` shortcut, so the pipeline:
```
$ ls /etc /non-existent 2>&1 | grep passwd
passwd
passwd-
```
is equivalent to the shorter version:
```
$ ls /etc /non-existent |& grep passwd
passwd
passwd-
```
To prove that stderr also gets filtered through `grep`, try to run:
```
$ ls /etc /non-existent |& grep -e passwd -e non-existent
ls: cannot access '/non-existent': No such file or directory
passwd
passwd-
```

A handy example of redirecting both stdout and stderr is when your last command is a `tee` call to a log file. You want to catch everything and write it to that log file, not just the messages written to stdout.

## Exit codes

By default, the exit code of a pipeline is the exit code of the last command (the rightmost one).

Taking the example above:
```
ls /non-existent |& grep passwd
```

The final exit code of the whole pipeline is `grep`‘s own one:
```
$ ls /non-existent | grep non-existent

$ echo $?
0
```
Notice that `ls` returned an error and this is something you want to handle in most cases. From a security standpoint, this is something you want to handle in all situations.

## Handling failing command

There are two solutions for entirely handling failing commands in a pipeline.

First is using the `PIPESTATUS` array variable. It contains as many elements as commands in the previous pipeline, with each element being the exit code of that command.
```
$ ls /non-existent | grep non-existent

$ echo $? - ${PIPESTATUS[@]}
0 - 2 0
```
Notice the error code 2 of the `ls` command. So if a pipeline is fully successful, then the sum of all elements of `PIPESTATUS` should be zero.
```
$ ls /non-existent | grep non-existent

$ for EXIT in ${PIPESTATUS[*]}; do let SUM+=EXIT; done

$ if (( SUM )); then
    echo there was an error >&2
    exit $SUM
  fi
```
or simpler, just bail out at the first non zero code:
```
$ ls /non-existent | grep non-existent

$ for EXIT in ${PIPESTATUS[*]}; do
    if (( EXIT )); then
      echo there was an error >&2
      exit $EXIT
    fi
  done
```
If you don’t want to go through every exit code of the pipeline, you can use the `pipefail` shell option. If set (via `shopt -s pipefail`), this option causes the entire pipeline to fail with the exit code of the rightmost command that has a non-zero exit code. In our simple example above, the pipeline would fail with code 2 (exit code of `ls`).

## Negation

You can even negate the exit code of the pipeline. That’s a logical negation. Logical means that any value different than zero is considered _false_ and zero is considered _true_. Negation means that if the entire pipeline returns an exit code different than zero, then the condition is considered _true_, or _false_ otherwise.

This a straight logical condition:
```
if ls /non-existent | grep non-existent; then
  echo everything ok with the pipeline
else
  echo something\'s wrong with the pipeline
fi
```
And this is its negation:
```
if ! ls /non-existent | grep non-existent; then
  echo something\'s wrong with the pipeline
fi
```
You can see that the message indicates an error, but the condition that is passed to the `if` condition has to evaluate to _true_ in order to execute the `echo` command. Which is exactly the `else` branch of the direct condition.

There you have it, I hope this helps you write better and more optimal pipelines in the future. And as an exercise, you can try and fix the existing ones, if you find any.

