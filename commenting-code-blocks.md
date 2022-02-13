# Commenting code blocks in bash

Do you know how controversial the block commenting problem is in the Python world? Well, in bash this is simpler to address, yet still controversial – purists, you know who you are 🙂

I know, most editors support prepending the hash sign to every line of a selected block. But from some reason, I find this quite high maintenance. Let me explain why.

For example, when I’m testing some patch, I want to disable an entire code block from being executed. If I prepend all lines with hashes I will generate a diff as big as the code block. If that code block is 3 terminal pages long… your eyes are in a bit of trouble.

And so, I have found myself numerous times having to think about a way to comment out a large chunk of code. There are LOTS of them, I’m only pointing out some of them with upsides and downsides.

Most of these should generate a clean diff in that it should add as little code as possible. You might also leave them unindented so that they are obvious in the eyes of the reviewer if the code block stays commented in a commit.

## Conditional and loop blocks

All these have in common the fact that the condition is never fulfilled and so the block is never executed. Bash will only consume memory parsing the block, but will never enter and execute it.

Probably the cleanest and most common one is

```
if false; then
...
fi
```

Of course, there are other conditionals you can use, like part of a loop.

```
while false; do
...
done
```

or

```
until true; do
...
done
```

but the one based on if seems the most obvious one.

You might want to stick a comment on the first and even on the last line, to make it even more obvious that the code is disabled:

```
if false; then # Disabled code due to ...
...
fi # Disabled code ends here
```

## Subshell that exits right away

I admit this one is weird.

```
( exit
...
)
```

Yes, I know what you’re thinking, this executes a subshell, but it’s also clean enough and it exits immediately after forking it. I actually used this a few good times.

## OR lists

This version doesn’t use a subshell. It only groups the commented code inside a compound list and prepends it with an OR condition (||). Thus, it never gets executed. My preferred bash builtin alternative to true is the null command :.

```
: || {
...
}
```

or a bit more easier to read to the untrained eye `true || { ... }`.

## Here documents

Lastly you can use here documents via

```
: <<'EOF'
...
EOF
```

I formed a habit to use EOF as my marker for all my here documents, so if the commented code contains them, you might want to use something else for commenting. Like maybe even : `<<'DISABLED' ... DISABLED`.
