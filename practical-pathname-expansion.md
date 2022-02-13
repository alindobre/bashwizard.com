# Practical pathname expansion

One of the most common situations where folks get confused is when they want to iterate through all or some of the files inside a certain directory. Iterate = a `for` loop, files list = `ls`. Right? Nope! The correct answer is the pathname expansion.

I challenge you, look through the results from a GitHub search of `for in ls`. It wasn’t hard for me to find out examples for this blog post. And reasons why folks fail to understand this essential bash feature.

## What is it?

So what is pathname expansion? It happens along with most of the other types of expansion, right after word splitting. In its simpler form, if those words contain any of the pattern characters `*` or `?` or `[]`, then bash will attempt to expand those patterns to the list of files AND directories matching them. The bonus is that it also alphabetically sorts the list. So `*.txt` is a word in itself, it contains `*` so bash will attempt to expand it to a sorted list of all files (and directories) whose names end in `.txt`.

In the situation when `extglob` is enabled, then a more complex set of patterns are being scanned for. I use these extensively, but I’ll keep things simple in this post. I’ll focus on the more straightforward pattern matching, explained above.

One situation where pathname expansion is required is more common than others. And that’s the `for` loop.

## Examples

What the GitHub search above is showing and what I’ve seen with my own eyes is people using something like:
```
for file in `ls *.txt`; do process $file; done
```
However, `ls` is a tool for displaying files for humans, not machines.

In the simplest form, the pure bash form of the above is:
```
for file in *.txt; do process $file; done
```
Throughout these examples I’ll use `process $file` as a fictional command that processes that file. In your case it will be whatever you want to do with that file or directory.

If you want to process only the files, then you can add a top condition inside the for loop like the following:
```
for file in *; do
  [[ -f $file ]] || continue
  process $file
done
```

Or you can similarly select only the directories:
```
for file in *; do
  [[ -d $file ]] || continue
  process $file
done
```

If you want to sort files in reverse, you can use an indexed array like this:
```
FILES=( *.txt )
for (( INDEX=${#FILES[@]}; --INDEX >= 0; INDEX )); do
  process ${FILES[INDEX]}
done
```
And now you know how to free yourself from that `ls`.
