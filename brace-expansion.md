# Brace expansion and why you no longer need seq

I’m here to tell you the naked truth. Not only bash knows how to do everything `seq` does, but it also does it better. There, I said it. I know, your older brother or your mentor taught you to write `for i in $(seq 5); do ...` but using pure bash is so much better. Curious how? Read on!

## History

Back in the 80s, when the shells were featureless, there was a strong case for `seq`. Coders needed a way to iterate through a sequence of numbers in their shell scripts. It was so early in the computers era that Perl didn’t even exist as a fallback alternative. But today, and even before one of the most stable and longstanding versions which was 2.05b, bash can do what `seq` does in a straightforward way.

Generating sequences is part of a feature called _Brace Expansion_. That’s because the special characters are the braces, along with the double dot and the comma. And I only say sequences and not sequences of numbers because bash knows how to deal with single letters as well.

## My real life usage: renaming files

In real life, I have to admit that I don’t use brace expansion for sequences. That’s because I rarely need to use them. I use brace expansion when I want to rename a file quickly or when I want to shorten the line in a script. Especially when I’m dealing with long full paths.

For example, if I want to rename a file by adding the `.orig` extension. I do that very easy with:
```
mv /path/to/file{,.orig}
```
I feel the need to clarify that the above expansion is done by bash before it executes `mv`. The actual execution string is:
```
mv /path/to/file /path/to/file.orig
```

Another example is when I want to rename a file with a completely different name:
```
mv /path/to/{file,newname}
```
That expands to
```
mv /path/to/file /path/to/newname
```
So the simplest brace expansion
```
{a,b}
```
expands to
```
a b
```
and
```
{a,b,c}
```
expands to
```
a b c
```
and these are the ones I use the most in real life. Whether I’m writing scripts or command line.

## Sequences

But back to sequences. Here’s how they work. The syntax is: `{FIRST..LAST[..INCR]}`
By the way, when a brace expansion is not valid, it’s left unchanged by bash. But in the syntax above, `FIRST` and `LAST` are mandatory. The `..INCR` is the increment/step and it’s optional. `FIRST` and `LAST` can be numbers or single letters and it doesn’t matter if `FIRST` is less or greater than `LAST`. If `FIRST` or `LAST` is a number and is prefixed with zero, the expanded numbers are zero padded. Let’s see all of these in action.
```
$ echo {1..5}
1 2 3 4 5
```

Descending order can be achieved with:
```
$ echo {7..3}
7 6 5 4 3
```

Or, printing numbers from 15 to 5 with an increment (in this case it’s really a decrement) of 3:
```
$ echo {15..5..3}
15 12 9 6
```

But the same above:
```
$ echo {15..05..3}
15 12 09 06
```
because 05 are 2 characters, so it’s padded with a single zero. However, check on the next one.
```
$ echo {015..5..3}
015 012 009 006
```
You did not expect this one, did you?! 🙂

## Letter sequences are just as useful

With letters, sequences are expanded in the same way, except there’s no zero padding.
```
$ echo {a..f}
a b c d e f
```
while descending order goes like:
```
$ echo {f..b}
f e d c b
```
and last one, with increment:
```
$ echo {a..z..5}
a f k p u z
```

## Preventing brace expansion

As usual, if you want to temporarily prevent bash from expanding a string that is a brace expansion expression, then you can quote it:
```
echo \{1..3}
```
or
```
echo "{1..3}"
```
will both print the literal `{1..3}`

That’s it. No need for `seq` now, isn’t it? You see, when you use `seq`, you have to spawn it in a subshell, which is a lot more expensive than using bash builtin functionalities.
