# Bash redirections in broader contexts

Everybody uses redirections. Whether it is to or from `/dev/null`, or a file, or even a command. But every so often I see sequential commands redirecting their output to the same place. A proof that very few grasp that you can use bash redirections in broader contexts, like compound commands, groups or blocks of code.

## Brace list

Take the following example:
```
command1 2>/dev/null
command2
command3 2>/dev/null
```
There is, indeed, the case where we need the stderr information from `command2`, but in real life, I’ve found that quite rare. For all the other cases, when we don’t need the stderr of `command2`, we can group all the three commands under the same umbrella with the brace compound command:
```
{ command1
  command2
  command3
} 2>/dev/null
```
And this is probably the most common grouped redirection I’ve seen out there. I am biased here, but that the second form looks more logical and organised.

But wait, there’s more 🙂

## Loops

You might have already noticed my `grep` replacement filtering article where I’m passing the contents of a file via the input redirection, directly to the `while` conditional. Well, it goes the other way as well.

Let’s say you have to execute an `lslocks` command once every second for one minute, prepend that information with the current date and time, add a delimiting line, and redirect everything in the same file. The whole `while` loop can redirect its output to the same file, and you don’t even need to use the append mode:
```
while (( SLEEP++ &lt 60 )) && sleep 1; do
  echo ====
  date
  lslocks
  echo
done >/tmp/output
```
Not only all four commands from within the while block will redirect their output to the `/tmp/output` file, but also the conditional command will do so. So the above could easily be replaced with:
```
while (( SLEEP++ < 60 )) && sleep 1 && echo ====; do
  date
  lslocks
  echo
done >/tmp/output
```
and you’ll get the same result.

We can use the `for` loop in the same way. Then the `case`, `select` and `until` blocks, they are all similar in this. The two conditional compound commands `(( ))` and `[[ ]]` also fall into this category.
