# Proper handling of return/exit codes

I often see coders being confused about how to use the return/exit code of a command. There isn’t a consistent message about when `$?` should be used or whose command it belongs to in the first place.

## Conditionals vs. `$?`

First of all, it needs to be clear that the if and while constructs consider the exit code of the conditional command and execute one branch or another accordingly. This means that the following piece of code:
```
if command; then
  true dat
else
  no way
fi
```
will first execute command and wait for its completion. If its exit code is 0, then it will next run true dat. If the exit code is different than 0 (yet, still a number), then it will execute no way.

The `$?` variable is automatically populated by bash with the return code of the previously executed command. We’ll see later on what does this mean, but let’s take the simple command we used in the if conditional above.
```
command
if (( $? == 0 )); then
...
fi
```
The above code introduces an unnecessary reference to the `$?` special variable, since the `if` instruction considers the exit code by default. More, I’ve seen multiple mistakes when coders modified the code and added another call between `command` and `if`, thus changing the context of `$?`.

The forms:
```
if command; then
```
or
```
while command; do
```
are simple and clear in reference to the command execution and exit code.

## Exit code

The actual exit code should be between 0 and 127. Values starting with 128 and higher are reserved for the exit codes caused by signals. So if an application is killed by signal 9, then it will exit with code 128+9=137. Anything above 256 will overflow, so 257 actually means 1, as does 513.

Usual places where you return exit codes are inside functions using the `return` command or using the `exit` command if you want to exit the bash session entirely. The actual code is the argument for either of these two commands.

Examples:
```
return 3
```
Will cause the function that runs that code to exit with code 3.

```
exit 5
```
Will cause the script to exit with code 5, regardless where exit is called from (a function or the main script code).

Leaving the commands without arguments will cause bash to consider the exit code the one from the last command executed. This means that the return `$?` or `exit $?` forms use the `$?` variable redundantly and confuse other people.
```
command
return
```
will use the exit code of command to exit the function it’s called from.

## Sourcing also returns

Another place where one can use `return` is when the current script file is being sourced. This operation will be executed in the same context as the main script. The environment of the calling script gets modified by the script being sourced. This is why using `exit` will cause the parent shell session to exit. If you want an early return from a `source` command, you can use `return`, just as you would do in a function.

If the main script runs the following command
```
source test.sh
```
and the `test.sh` file contains:
```
command1
if command2; then
  return
fi
command3
```
Then if the exit code of `command2` is 0, then the `source` call will return 0 early and skip execution of `command3`. If the exit code of `command2` is 1, then `command3` is also executed. Notice the `return` command taking the exit code from the last command executed, in this case `command2` and not `command1`.

## Pipes

Pipes are another special case for the exit codes. When you run a pipeline of `command1 | command2 | command3`, then its exit code is the one of `command3`. The exit codes of `command1` and `command2` are ignored. If you want for the pipeline to fail in case any of the commands return a non-zero exit code, then you have to set the `pipefail` option (`shopt -s pipefail`).

Regardless of the exit code of the entire pipeline, you can still obtain the exit codes of individual commands by accessing the special builtin array variable `PIPESTATUS`. For the example pipeline above, the exit status of `command2` is `${PIPESTATUS[1]}` (indexes start from zero).

## When is $? useful?

I’ve mentioned a couple of cases when `$?` should not be used, so when is it useful? I’m only using it when I want to save the exit code of a command for later, and by later I don’t mean the following command. Like in the following example:
```
command1
ERR=$?
command2
command3
if (( ERR )); then
  echo command1 returned an error
fi
```
There you have it. Now you can master the exit codes in a simple, optimal and non-confusing way. 
