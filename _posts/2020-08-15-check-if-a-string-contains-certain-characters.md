---
layout: "post"
---

# Check if a string contains certain characters

As with all in bash, there is no good or bad solution when it comes to checking if a string contains certain characters or substrings. It mostly depends on the rest of the script or the collection, the coding style and your personal preference. So let’s crack on.

## Options

There are several takes on this matter: either you are searching for characters in a specific order or you are searching for characters (or groups of characters) anywhere in the string in any order. The main difference between the two is the amount of asterisks and pipe characters.

Regardless of the order, my go-to method is using the bash’s own pattern matching feature. 

## Single ordered characters

Let’s start with single character. If you want to check if string `My string` contains the character `t`, the pattern you want to use is `*t*`:
```
if [[ "My String" == *t* ]]; then
  echo t was found
else
  echo t was not found
fi
```

As always, when you have only one command in each conditional branch, using the short logical form reads better. So the above can be shortened as:
```
[[ "My String" == *t* ]] && echo t was found || echo t was not found
```

However, the short version must be used with care and only if you’re fairly confident that the middle command won’t fail – such as an `echo` without any redirection – otherwise the rightmost command will execute when either the first or the second command fails.

This was historically the area where the `case` instruction was being used. So the same code as above can be illustrated with it:
```
case "My string" in
  *t*)
    echo t was found
    ;;
  *)
    echo t was not found
    ;;
esac
```
or going for a more compact and neatly indented `case` such as:
```
case "My string" in
*t*) echo t was found     ;;
  *) echo t was not found ;;
esac
```

Again, the pattern `*t*` doesn’t change across all the above examples. This is for finding just one character. But, let’s explore the other options.

## Multiple ordered characters

You can check for multiple ordered characters simply by extending the pattern to the right. So if you want to check check if `t` is contained, but later on `n` is contained too, you can use the `*t*n*` pattern.

If you want to match strictly consecutive characters, you can use, for example `*t*ng*`.

Or, if you want to match those that end in `ng`, use `*t*ng`. Or if the string starts with `M`, you can use `M*t*ng`.

## Single and multiple unordered characters

What do you do when you want to check for characters or groups of characters that don’t come in a specific order? You use the pipe to distinguish multiple wildcard groups. Say you want to check if the string contains the `n` and the `s` characters, but in no particular order. You then use the pattern `*@(n|s)*` which translates to _any character before, then either `n` or `s`, then anything after_.

Groups of characters? No problem. Let’s see if `My string` contains any of the `ng` or `st` groups in no particular order:
```
[[ "My string" == *@(ng|st)* ]]
```

## Regular expressions

Notice that I haven’t yet used the regex operator yet. That is available and you probably guessed how to use it to check if the string contains the character `t`: `[[ "My string" ~= t ]]`.

This is the simplest pattern, but I’m sure that you can extrapolate further. I personally almost never use the regex operator, unless it makes really sense in the context. Wildcards work for me in most cases.

That’s it. I hope it will now be easier for you to check if a string contains certain characters or substrings in pure bash without using any other external tool.

An approach similar to this post is using pure bash instead of grep when looking for patterns in files or variables.

Shoutout to _aioeu_, _tigger04_, _oh5nxo_ and _geirha_ reddit users for reading and contributing to this post indirectly via reddit comments. You folks made the world a better place!
