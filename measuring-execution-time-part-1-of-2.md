# Measuring execution time with bash (part 1/2)

Things seem comfortable when you want to measure the execution time of a single command at a shell prompt. You can even use your phone's chronograph for this. However, what are your options when you want to automate this task and your code is a lot more complex? Read on!

## The `time` reserved word

The `time` reserved word is suitable for being used when you have a simple command. Because it’s a reserved word, it can also compute times for a pipeline. Another advantage is that you also get the system and kernel CPU times. That’s useful when your code does some advanced testing of the resources computed.

Notice that `time` is a reserved word. You can find it explained in the _Pipelines_ section of the man page. You have to treat it as a reserved word and not as a command or anything else because you’ll notice it doesn’t work as you’d expect in all situations. Redirecting its output might be problematic, for example.

## Examples

Let’s see `time` in action. I’m going to use the POSIX mode (via the `-p` argument) because the POSIX format is a lot easier to parse by default.
```
$ time -p sleep 3
real 3.00
user 0.00
sys 0.00
```

Alternatively, let’s see it in action with pipes. We can pipe multiple `sleep` calls, with the right one longer:
```
$ time -p sleep 3 | sleep 4
real 4.00
user 0.00
sys 0.00
```
It’s obvious now that the entire pipeline was measured since the execution time considered the longest sleep.

## Quirks

The most significant disadvantage of using the `time` reserved word is when you need to parse its output, which means at least saving that output into a temporary file and parse that file afterwards. Alternatively, piping its output to another parsing command. Not ideal.

Worse, if you want to catch the output of the time reserved word and not the one of the leftmost command of the pipeline, then you need to run the pipeline inside a subshell. Otherwise, any redirections are applied to the pipeline itself – more specifically, to its leftmost command.
```
$ time -p ( sleep 3 | sleep 4 ) 2>/tmp/time-output
```
or
```
$ ( time -p sleep 3 | sleep 4 ) 2>/tmp/time-output
```

## Output format

I mentioned that the POSIX mode is easier to parse by default, but you can format the output yourself via the `TIMEFORMAT` variable. The default value of this variable is `$'\nreal\t%3lR\nuser\t%3lU\nsys\t%3lS'`. Check the bash manual if you want a more in-depth explanation on this variable. However, you can use `$'\n%0R'` to print just the seconds without any other prefixes.
```
( # we use a subshell so we don't modify TIMEFORMAT for
  # the entire shell session
  TIMEFORMAT=$'\n%0R'
  ( time sleep 3 | sleep 4 ) 2>/tmp/time-output
  read REALTIME </tmp/time-output
  echo Execution time: $REALTIME
)
```

## The `times` builtin

There is another similar bash builtin called `times`. This really is a builtin, so it acts like a normal command, you won’t have too many problems catching its output. However, the usage is a lot more rigid. No formatting, no arguments, nothing. You get what it gives you. It only shows the accumulated user and system times from the same sources as the time reserved word. No real execution time, though, this can be computed manually with methods I’ll explain in the second post of this blog topic. Just that it does this for the current shell and all of its child processes.

The way I’ve used it in the past was grouping all the commands in a subshell and computing the system and user times of that subshell. This is a good source of measuring and reporting metrics in QA, Monitoring, Obsevavility and other areas.

## GNU time

An alternative to these two bash features is the GNU `time` command. It is a more advanced and, I’ll give you this, more powerful command. You will find that GNU `time` is able to compute more metrics and more formatting options. However, it isn’t installed by default in most distributions.

