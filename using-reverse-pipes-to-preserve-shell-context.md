# Using reverse pipes to preserve shell context

Every so often I see bash scripts that follow the pattern:
```
NODEID=`curl -s https://api.github.com/repos/alindobre/qemu/commits?per_page=1 | jq -r '.[] .node_id'`
SHA=`curl -s https://api.github.com/repos/alindobre/qemu/commits?per_page=1 | jq -r '.[] .sha'`
```
Sometimes I see even 3-5 variables extracted this way. Even worse, I noticed code with additional pipes added after `jq`, which perform very simple filtering when `jq` is a potent tool by its own.

The most upsetting problem with the above code is that is running `curl` two times. This can be translated to making twice the number of API requests. If you have five such lines in your script, you’re wasting your server computing capability with 4 times unnecessary requests.

Normally, to fix this problem, you’d only make a single request and use `jq` to output both values in the same run.
```
curl -s https://api.github.com/repos/alindobre/qemu/commits?per_page=1 \
  | jq -r '.[] | .node_id, .sha'
```

The first instinct might be to continue with another pipe like this:
```
curl -s https://api.github.com/repos/alindobre/qemu/commits?per_page=1 \
  | jq -r '.[] | .node_id, .sha' \
  | { read NODEID
      read SHA
      echo NODEID=$NODEID
      echo SHA=$SHA
    }
echo NODEID=$NODEID
echo SHA=$SHA
```

The second set of `echo` calls are outside of the pipe subshell in the parent shell context. And because you can never modify parent’s environment from a subshell, those two `echo` calls will output empty values.

What I call a reverse pipe is using the triple input redirection from a command substitution. In this case, the input goes from the subshell to the parent command and not the other way around. Let’s see it in action:
```
{ read NODEID
  read SHA
  echo NODEID=$NODEID
  echo SHA=$SHA
} <<<`curl -s https://api.github.com/repos/alindobre/qemu/commits?per_page=1 \
      | jq -r '.[] | .node_id, .sha'`
echo NODEID=$NODEID
echo SHA=$SHA
```
What happens is that I took the last pipe from the previous command and execute it in the context of the parent. So now, the second pair of `echo` calls will no longer output empty values. That’s because the read commands are executed in the context of the parent shell.

I hope this example was useful enough in the quest of reducing the number of pipes and subshells, especially when using network calls. And give `jq` more credit. It’s a very powerful tool on its own capable of advanced output filtering. You don’t need to use additional `grep`, `sed`, `awk` or `tail`/`head` calls.
