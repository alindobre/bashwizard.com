# Shells, subshells and PIDs

Sometimes you need to find out the PID of your running shell. But when your current code runs in a subshell instance, you might get confused about the difference between the `$BASHPID` and `$$` variables.

One note here, the `BASHPID` variable has been introduced in bash version 4.0, so it’s not present in any versions that are older than that.

## Uh, subshells?

First of all, you might wonder, what is a subshell and how it differs from a... shell?

Well, a full-blown shell is one when bash is executed and initialized. So whenever you actually execute `/bin/bash` or a script that starts with the shell magic `#!/bin/bash`, that’s when you call it a shell.

On the other hand, a subshell is considered the execution environment where the code is executed between round brackets or when a pipeline involves a shell `builtin` command rather than a regular executable. For example, `grep` and `cat` are executables, they’re going to be executed on their own. However, when you run `ulimit` or `printf`, because they’re bash builtins, if they’re part of a pipeline they are executed as subshells. Asynchronous commands (like `command &`) and command substitutions (like `$(command)`) are also executed in their own subshells.

## Environment handling

Two important environment variables are populated for shells only: `PPID` and `SHLVL`. All the code that shares the same shell context has the same `PPID`, the PID of the parent process that launched that shell, and `SHLVL`, the _shell nesting level_. This latter variable starts with 1 and is incremented every time a new shell session is launched.

When you want to find out the PID of your current shell session, even from subshells, that’s when you use `$$`. Any subshell has its own PID as well, and you can access it via the `$BASHPID` variable. I couldn’t find a logical way of remembering these two, though. In my head, they sound exactly the opposite of their meaning. But, they’re already implemented as they are, nothing to be done here, carry on. Just remember one of them and you’ll be fine.

## Example script

The following example script will point out how the values of these four important variables are changing with shells and subshells:

```
#!/bin/bash

echo sh1 $\$=$$ BASHPID=$BASHPID PPID=$PPID SHLVL=$SHLVL
( echo ss1 $\$=$$ BASHPID=$BASHPID PPID=$PPID SHLVL=$SHLVL \
  | { read LINE
      echo $LINE
      echo ss2 $\$=$$ BASHPID=$BASHPID PPID=$PPID SHLVL=$SHLVL
    }
)
bash -c 'echo sh2 $\$=$$ BASHPID=$BASHPID PPID=$PPID SHLVL=$SHLVL'
```

Running the above code on my machine, yielded:
```
sh1 $$=797 BASHPID=797 PPID=756 SHLVL=2
ss1 $$=797 BASHPID=799 PPID=756 SHLVL=2
ss2 $$=797 BASHPID=800 PPID=756 SHLVL=2
sh2 $$=801 BASHPID=801 PPID=797 SHLVL=3
```
Each line represents a shell (_sh1_ and _sh2_) or a subshell (_ss1_ and _ss2_). The subshells only have the `BASHPID` variable changed, when compared to _sh1_, which is their containing shell session. The second shell session has the first shell as a parent PID and increments `SHLVL`. Remember, because bash is being executed, it’s a completely new shell session.

You might be confused about the read+echo pair in the pipe, but let me explain that a little. What happens is the _ss1_ `echo` will write its data at stdout. That data is then piped through the subshell that runs the code in between `{` and `}`. The first line of this second subshell will read the piped data and will put it into the `LINE` variable, and the second line will print it. So the data of the _ss1_ subshell is printed out at the console by the _ss2_ subshell. I did that only to make use of the pipe stdout/stdin data.

I find myself using `BASHPID` more frequently than `$$`, only because the need of finding out the PID of the current subshell comes in more often. When writing out the PID number to a file, I find that is handier to use the more specific `BASHPID` number. However, when you want to run a logger pipe that prints the entire output to syslog, you might consider `$$` instead so that all subshells of that script will output the same PID to distinguish different script run sessions.

So, next time you’ll find yourself trying to find out the PID of the current session, whether it’s the containing shell or the current subshell, you’ll know which one to use.
