# Replace date with printf

I get it, you’re attached to `date`. It served you well. All these tens of years we have used this simple yet effective binary to give meaning to our logs and backups. Those days are gone. Now, you can do all that in pure bash. Interested? Well, the title did give it away, so... I present you: `printf`.

First, let’s explore how this `printf` is a replacement. Starting with bash 4.2, the date format feature was added to `printf`. Since it was released in 2011, I can only assume that most currently supported distros out there have this feature. I haven’t met one that didn’t.

But `printf` isn’t simply a 1:1 replacement for `date`, it’s more than this. That’s because it has the ability to directly populate an environment variable, thus eliminating the need of a subshell completely.

So if you want to create a variable `$TODAY` that contains the current date, you used to run:
```
TODAY=`date +%F`
```

But now, it’s as simple as:
```
printf -v TODAY "%(%F)T"
```
You can replace the `%F` above with any date/time format that is supported by the `strftime` system function.

There is a catch though. On older versions of bash – such as the one shipped with CentOS 7, the above code will assume that the current date is the beginning of the Unix epoch. To force the current date, you have to add another argument at the end of the `printf` call:
```
printf -v TODAY "%(%F)T" -1
```
Done. Simple, isn't it?
