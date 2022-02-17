# To quote, or not to quote, that is the question

When was the last time you quoted a bash string just because you were not sure about if the characters that are contained are treated specially by bash? The worst part is that this commonly happens even when defining constants.

I know about security, I know that having strings from end-users require special attention so we don’t end up executing code we don’t intend to. But these aren’t the cases I’m referring to.

Two major situations where quotes are most probably not needed are:
* variable assignment to a constant value
* echoing simple strings

## Assigning a constant

When you assign a constant string to a variable – because I remind you, values stored in variables are only strings, there no integers or any other types in there – you already know its contents. Because it’s a constant. And most variables I’ve seen only contain one English word or a number.

So when you do assignments like `A="1"`, the quotes are two extra characters that are redundant and nothing else than fillers. They don’t add value, they add visual discomfort, confusion amongst other less experienced users who use your scripts as examples. For me, when I see it, I see _I am insecure about the things I need to quote so I quote when in doubt_. Or even worse, some people don’t even know they can assign unquoted values.

## Echoing simple strings

The second major case is when people echo stuff. Unlike in other programming languages, where messages are passed as strings which need to be quoted, in bash strings are made up of words and special characters. And the whitespace is somehow a blessing because it’s also used to split arguments. Lots of blah blah, I know, but what I said translates to:

```
echo one two tree
```

displaying the same as

```
echo "one two three"
```

So the above makes the quotes, you guessed already, redundant. I know that sometimes English words such as _can't_ contain special characters. If you only have one of those, you can use backslash to quote it. You introduce only an extra character, the backslash, versus two of them, if you would quote around it.

## Consistency is better than purism

If you have lots of strings with special characters across your script, then you can use quotes just to maintain a consistent coding style. But otherwise, the default style should be missing unneeded quotes.

You also need to keep up with the style of the whole script. If you add some minor changes to a script that already uses `echo "string"` or `A="1"`, then you either refactor the whole script with stripped quotes or use quotes for now and refactor later. But the idea is to not break the style just because I told you that quotes are sometimes redundant.

Even today, I still couldn’t tell you the whole list of characters that are considered special by the shell, but I developed a habit of recognising them. When in doubt, I don’t quote but I actually read the bash manual at the DEFINITIONS section. Give it a read, there are so few special characters, you’ll be amazed!

## Conclusion

In short, I use quotes when I have:

* whitespaces
* dollar signs $ or backticks `
* round brackets
* command terminators: semicolon, ampersand and pipe.
* redirection characters

One pair of characters that are always seeding doubt in my mind are the square brackets or even the curly ones. But don’t worry, you can safely assign the value `xyz[]` to the `X` variable by doing a simple `X=xyz[]`. Same goes for `X=xyz{`. Wow, that unclosed brace kills me! Yet it’s just a string 🙂

