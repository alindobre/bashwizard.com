# Loop over file names without using `ls`

This is a common misconception coming from old bash versions or old shells altogether. When executing loops over file names, the `for` loop has direct support for path expansion which means you don’t have to use `ls` in a subshell to obtain the same result.

# The form using a subshell

This form is very commonly used, even though it uses a subshell and it’s less visually appealing – obviously, this is personal opinion.
```
for FILE in `ls /etc/*rel*`; do ... $FILE ... ; done
```
Spawning a subshell that executes `ls` can be expensive and most probably the reason why this form is so common is because there is little knowledge of the bash-only alternative.

# Bash-only `for` loop over file names

In the vast majority of the times you need to use `ls`, the following form works just as well:
```
for FILE in /etc/*rel*; do ... $FILE ... ; done
```
Whatever wildcard filter you’re passing to `ls`, works with bash too. Mostly because before it’s passed to `ls`, bash expands `/etc/*rel*` to the actual filenames that match it.

This form of looping over file names uses the bash feature called pathname/filename expansion. I also use it very often with arrays, such as:
```
ARR=( /etc/*rel* )
```
and then further process the `${ARR[*]}` contents.

# The `nullglob` case

By default, the `nullglob` feature is not enabled in bash. This causes the unmatched patterns to be sent as-is as input to the bash constructs. To avoid this, set `nullglob` in advance, usually at the beginning of your script:
```
shopt -s nullglob
```
So whenever a pattern doesn’t match any existing file, it will be expanded to null, which means a `for` loop won’t execute at all.

## Conclusion

I’m done judging which form is better. In many cases, not having to spawn a new subshell can translate to more stability when the machine is under load. In some other cases, it looks clearer without the backquotes and the `ls`.

However, if you were using the `ls` form before, just know that there is a bash-only alternative to executing a loop over file names.
