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
