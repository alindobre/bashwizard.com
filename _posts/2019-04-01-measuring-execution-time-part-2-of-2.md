# Measuring execution time with bash (part 2/2)

In the first part of this topic, we’ve seen what bash (and GNU) offers in terms of commands specially designed to measure the execution time and resource consumption. However, in some situations, that’s not enough, and you have to measure the execution time manually.

You can achieve this in two similar ways. Get the epoch time at the start and the end of the execution block and compute the difference. Let’s see it in action.

What’s epoch you’re asking me? It’s the number of seconds since 1st of January 1970. About 1.5 billion seconds so far, so we’re good.

## The printf builtin

In bash 4.4 or older, you can use the `printf` command to populate a variable with the current epoch time in seconds.
```
printf -v TIMESTART "%(%s)T"
# execution block
printf -v TIMESTOP "%(%s)T"
echo Execution lasted for $((TIMESTOP - TIMESTART)) seconds
```

## EPOCHSECONDS

In bash 5.0, you can use the new predefined variable called `EPOCHSECONDS` to compute the execution time of a code block:
```
TIMESTART=$EPOCHSECONDS
# execution block
TIMESTOP=$EPOCHSECONDS
echo Execution lasted for $((TIMESTOP - TIMESTART)) seconds
```
Obviously, we could have used directly:
```
echo Execution lasted for $((EPOCHSECONDS - TIMESTART)) seconds
```

## EPOCHREALTIME

There is also a microsecond granularity variable called `EPOCHREALTIME`. It’s also available starting with bash 5.0. However, we can’t use pure bash to compute the difference between two floating point numbers directly, so we have to use some external tool for this purpose.
```
TIMESTART=$EPOCHREALTIME
# ... execution block
TIMESTOP=$EPOCHREALTIME
echo Execution lasted for `bc "$TIMESTOP-$TIMESTART"` seconds
```
Yep, you guessed already, you need `bc` installed. But if you ever had to compile the kernel on the same machine, you’re sorted, you already have `bc` installed.
