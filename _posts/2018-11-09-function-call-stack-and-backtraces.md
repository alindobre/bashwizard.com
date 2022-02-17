# Function call stack and backtraces

Enabling tracing with `set -x` is a good way to debug, but sometimes that’s either not enough or too much. There are situations you need to display the execution call stack at some point in a script in the form of a backtrace. This kind of functionality was a real saviour when I was debugging scripts that were too silent (having both output descriptors redirected to `/dev/null`).

## Functions and libraries

The truth is that the longer the script, the more you need to break it into separate functions. The more functions you have, the more you need to split them among different library files, to be subsequently sourced. And it’s really easy to get lost in the whole function call stack.

In this article we’ll use a simple script `/tmp/script.sh` that calls a simple library `/tmp/library.sh`.

The contents of the script reads:
```
#!/bin/bash
. /tmp/library.sh
call:me
```

The contents of the library go like this:
```
call:me() {
  callception
}

callception() {
  echo Where the magic happens
}
```

So basically the main script calls the call:me function, which in turn calls the callception function, which at this point does nothing than displaying a message:
```
$ /tmp/script.sh
Where the magic happens
```

## The function call stack

You see that even though it’s a simple message displayed at the output, inside the script the call stack is three levels deep. And this is what happens in real life. You sometimes only see a message, but the script executes tens or hundreds of functions behind the scene. And those are the times when it gets complicated to inspect the code as it runs.

This is where `FUNCNAME` variable comes to help. It’s an indexed array (so it starts from `FUNCNAME[0]`, then `FUNCNAME[1]`, ...) with each element containing the names of all functions that are in the execution call stack at the time `FUNCNAME` is accessed.

So now, if we change callception to:
```
callception() {
  echo ${!FUNCNAME[*]}
  echo ${FUNCNAME[*]}
}
```
then we get:
```
$ /tmp/script.sh
0 1 2
callception call:me main
```
When you call an array with `${!ARRAY[*]}` it expands to the key names or index numbers of that array. So what the above output tells us is that
```
${FUNCNAME[0]}=callception
${FUNCNAME[1]}=call:me
${FUNCNAME[2]}=main
```
You see, there is a particular name for the main code, which is literally `main`. Remember that if you have a function called `main()` in your code, you might get confused over which is which.

## The source of each function call

You can do more than just displaying the function stack. You can show the source file of each function with the `BASH_SOURCE` array. Again, this is an indexed array like `FUNCNAME`. For each index of `FUNCNAME` you get its corresponding source via the same index number of `BASH_SOURCE`.

To put it in perspective, let’s change the callception function again:
```
callception() {
  echo ${!FUNCNAME[*]}
  echo ${FUNCNAME[*]}
  echo ${BASH_SOURCE[*]}
}
```
With the above, the script will display:
```
$ /tmp/script.sh 
0 1 2
callception call:me main
/tmp/library.sh /tmp/library.sh /tmp/script.sh
```
So `${FUNCNAME[0]}` is `callception` and its located in the `/tmp/library.sh` file (the value of `${BASH_SOURCE[0]}`). Same goes for `call:me` and then the main script is located, well, in its own file.

## The line number

Not only you get the file, but you also get the line number in that file where the function call is located. The variable holding these values is `BASH_LINENO`, again an indexed array similar to the `FUNCNAME` and `BASH_SOURCE`, but with a trick: the index number is off by one. So for `FUNCNAME[1]`, you have `BASH_SOURCE[1]`, but `BASH_LINENO[0]`.

Let’s make the callception function even larger:
```
callception() {
  echo ${!FUNCNAME[*]}
  echo ${FUNCNAME[*]}
  echo ${BASH_SOURCE[*]}
  echo ${BASH_LINENO[*]}
}
```
And the script would display:
```
$ /tmp/script.sh 
0 1 2
callception call:me main
/tmp/library.sh /tmp/library.sh /tmp/script.sh
2 3 0
```
So `${FUNCNAME[1]}` is `call:me`, defined in `${BASH_SOURCE[1]}` (`/tmp/library.sh`) and called at the `${BASH_LINENO[0]}`, which is line #2.

## Glueing all together

Let’s use a for loop like real programmers 🙂
```
callception() {
  local i
  echo ${FUNCNAME[0]}@${BASH_SOURCE[0]}:$LINENO
  for (( i=1; i<${#FUNCNAME[*]}; i++ )); do
    echo ${FUNCNAME[$i]}@${BASH_SOURCE[$i]}:${BASH_LINENO[$i-1]}
  done
}
```
I usually define a function that does all the dirty job and instead of running echo it sends everything to the syslog via logger, so I get the backtraces in the system log. Another trick is to remove the first element of the stack because, well, you already know where you’re calling from. In the above code, that’s the `echo` above the `for` loop. Ditch that and you’ll have an even cleaner code.

