# Displaying unique values

I have done it, you have done it, we’re all guilty of piping the output of some command to `sort | uniq`. What if I tell you that you can achieve value uniqueness by using pure bash code?

# The `sort|uniq` cases

In general, when piping the commands through the `sort | uniq` pair we’re not really interested in the sorting part. Most of the times we’re interested in the uniqueness part. But `uniq` can only function correctly if all the duplicates are one after another in the output. And this behaviour is achieved with the help of the additional `sort` call beforehand. Nowadays `sort` even accepts a `-u` argument, which will make the output not only sorted but also only with unique values.

There are further use cases to the `sort | uniq` pair. When we want to count how many duplicates each value has, we can no longer rely solely on `sort -u`, but we have to run `sort | uniq -c`. Which usually involves yet another pipe to `sort -n` because we want to see the lowest/highest count. And if the output is large, we only want the top 5 values, so we’ll pipe once more through `tail` or `head`.

## Pure bash

But let’s get back to the more straightforward use cases, which are also the ones used more often. The way to achieve uniqueness in pure bash is via associative arrays. Each string value will represent a key in that array. Each occurrence of that value can represent either a fixed arbitrary value or an incremented positive integer.

Let’s see it in action. I’m choosing the shells of the system users from a Linux system. The following statement will give you an unordered list of these shells:
```
while IFS=: read _ _ _ _ _ _ SH; do
  echo $SH
done </etc/passwd
```

Next, let’s try to obtain the unique values of these shells:
```
declare -A SHELLS
while IFS=: read _ _ _ _ _ _ SH; do
  SHELLS[$SH]=x
done </etc/passwd
for SH in ${!SHELLS[*]}; do  # recycling the SH variable
  echo $SH
done
```
There you have it. We have achieved uniqueness with no pipes, no subhsells, and nothing but pure bash code. The `${!SHELLS[*]}` parameter will expand to the list of keys/indexes of an array if you’re wondering.

But wait, we can make it even cooler! Let’s prefix the values with their duplicate count:
```
declare -A SHELLS
while IFS=: read _ _ _ _ _ _ SH; do
  let SHELLS[$SH]++
done </etc/passwd
for SH in ${!SHELLS[*]}; do  # recycling the SH variable
  echo ${SHELLS[$SH]} $SH
done
```
Boom! Here’s my way of replacing `sort | uniq`.
