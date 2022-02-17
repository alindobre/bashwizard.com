# Filtering content with bash instead of grep

I get it, `grep` is an advanced content filtering tool. I’m not _bashing_ its use. I do it on a daily basis, too. However, most of `grep` calls I’ve seen are for simple words or sometimes simple patterns. And that might come easier while you’re typing at the bash prompt, but might be too _expensive_ to do it inside a script.

The problem with using `grep` in these simple situations is that you’re dragging a whole lot of executable code. This code is most of the times executed in a subshell. That’s because you’re either using a pipe or using a command substitution, each of these spawning a shell of their own. There is the case when you’re using grep as a conditional - `if grep pattern; then`, but this is less common. The point is that this might be expensive for a very simple piece of code which could be written in pure bash.

The solution to content filtering in bash is using the `[[ ... ]]` compound command in a `while` loop. Here’s an example.

Say you want to filter the word GNU from the /usr/share/licenses/GPL-2 file. That translates to:
```
while read LINE; do
  [[ $LINE == *GNU* ]] && echo $LINE
done </usr/share/licenses/GPL-2
```
If you want two or more words, such as both _GNU_ and _License_, you can use the more advanced pattern matching, enabled by default via the `extglob` shell option:
```
while read LINE; do
  [[ $LINE == *@(GNU|License)* ]] && echo $LINE
done </usr/share/licenses/GPL-2
```
You can, of course, use the more classic and less compact version of the above:
```
while read LINE; do
  [[ $LINE == *GNU* || $LINE == *License* ]] && echo $LINE
done </usr/share/licenses/GPL-2
```

Or, you can stop after the first match:
```
while read LINE; do
  [[ $LINE == *GNU* || $LINE == *License* ]] && echo $LINE && break
done </usr/share/licenses/GPL-2
```
Or after 4 matches:
```
while read LINE && (( INDEX++ < 4 )); do
  [[ $LINE == *GNU* || $LINE == *License* ]] && echo $LINE
done </usr/share/licenses/GPL-2
```
The `=~` operator enables the use of regular expressions. Back to our first example, the regular expression version would read:
```
while read LINE; do
  [[ $LINE =~ .*GNU.* ]] && echo $LINE
done </usr/share/licenses/GPL-2
```
So, you see, you don't have to bother `grep` for simple stuff. Next time you want to filter content, do it with a simple bash loop.
