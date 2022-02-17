# Positional parameters: changing and handling them

One of the best features in bash programming is the ability to change and play with the positional parameters.

## The big Why?

Many times when I told someone about this _secret_, they hit me with the big question of _Why?_ Why would one want to do change the positional parameters of a function or a script?

Here’s my take on this. When you change the positional parameters, your variables are shorter (`$1`, `$2`, etc). You also benefit from using the `shift` builtin and you’re able to use `getopts` easier. All these capabilities can be translated to using arrays, but there’s nothing like the universal understanding of what `$1` means in a shell script versus using `${SOMEARRAY[1]}`.

## Practical examples

A practical example is when your script be configured via both a configuration file and script arguments. In this case, you can parse the configuration file and add the corresponding arguments, after that having a single place where you parse all those with `getopts`.

Another practical example is when your script is executed by a web server via CGI and your code would have to be convert a single slash separated path argument to a space separated list of arguments, again parseable with `getopts`.

Positional parameters contexts are _executed scripts, functions and sourced scripts_. This means that a function can have its own set of positional parameters. Or, when you source a script, you could add some positional arguments as well, and those will be passed on to the sourced script.

## Using the set command

The command to change the positional arguments is `set`. Yes, that same `set` that you can use to enable and disable some of the shell features.

To make sure you only reset the positional arguments, you can add a simple or a double hyphen right after `set` as follows:
```
set -- param1 param2 param3 -param4
```
Note that you can also use a single hyphen, but in this case, the behavior changes a little bit. If there are arguments that follow any of `-` or `--`, then they will be set as positional parameters. If no arguments follow the single hyphen, then the parameters list is left untouched. With the double hyphen, the parameters are cleared/unset. Also, when using the single hyphen, if `-x` is enabled (via `set -x`), you will not be able to see the `set` command in the debug output. The same goes for the `-v` option. When using double hyphen though, the two `-x` and `-v` options are visible as intended.

Although it’s supported, I never combine setting shell options and changing positional arguments in the same `set` command. I do this simply for clarity reasons. In my coding style, resetting the shell options happens at the very top of a script/function, while setting the parameters can happen later. I’ve also never met a situation when I had to use set in both these two contexts at the same time.

## Double digit positional parameters

And since we’re talking about positional parameters, here’s one more problem I’ve noticed. When  their number exceeds 9, they need to be referred to by double digits. Even though rare, when you need to refer to the 12th parameter, you have to enclose it with braces like `${12}` and not `$12`. The latter will be expanded by bash to the value of the first parameters `$1` concatenated with the string "`2`".
