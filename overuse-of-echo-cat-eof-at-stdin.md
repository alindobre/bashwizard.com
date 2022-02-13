# Overuse of echo, cat, EOF in common input redirections

In my experience, most of the code I’ve seen redirects output of stdout or stderr to `/dev/null`. Not only bash supports a lot more redirection potential than those, but correct input redirection seems to have been replaced by overused constructs, which are often slower.

## Lose the `cat`

I know that when you write a command at the interactive shell prompt, before using `grep`, you might want to peek inside the file, so you first do a `cat file` and then when you know what to filter, you press the up arrow on your keyboard and add `| grep pattern` at the end of the `cat` command. But the way you write oneliners and commands at the shell prompt should not decide how your scripts look like.

So constructs like `cat file | command` inside scripts use an unnecessary pipe and take longer to execute than a simpler input redirection `command <file`. More than this, lots of commands already consider a file as an argument by default. The `grep` example earlier can be replaced altogether with `grep pattern file`.

Or, you might even be able to get rid of `grep` entirely if you want to keep your code in pure bash. But that’s for another blog post.

## Be free of EOF

The `<<EOF...EOF` construct has been used for ages in lots of other shells, not only bash. It’s called _here document_ and it has the purpose of populating a multiline content embedded in your script without having to save it through a file on disk and use multiple commands to feed it.

Actually, deep down inside, bash sometimes decides to save that content to a file and transparently handle it for you.

It might come as a surprise to find out that EOF is an arbitrary word. If it makes sense in your code, you can use another word as follows:
```
command <<MODIFIED
...
MODIFIED
```
The above construct will send the text between the two appearances of the keyword `MODIFIED` to command’s standard input. And there you have it. You don’t have to use `EOF`. Hey, you don’t even have to use capital letters, but doing so makes them more visible to the reviewer’s eye.

## Ditch the echo

The most common code I’ve seen in this context is `echo word | command`. While this isn’t incorrect per se, it will create a subshell via the pipe and that costs resources.

The obvious replacement is to use the _here strings_, following the format command `<<<word`. This code doesn’t use any additional pipe or subshell, making the execution faster. Not only that, but this form of input redirection is the most powerful and flexible one. That word can even have multiline content, like in the following code:
```
while read FILE; do
  read START <$FILE
  [[ $START == *GNU* ]] && echo $FILE
done <<<`find /usr/share/doc -type f -name \*.txt`
```
Running the above will display the files which have the word `GNU` on their first line. But the important bit here is that the find command will populate the stdin of the `while` loop with multiline content – one file on each line.

So there you have it. You can now finally reduce the overuse of `cat` and `echo` pipes, as well as make more sense out of your code by using something else than the old `EOF`.
