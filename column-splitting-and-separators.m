# Column splitting and separators

You know when you tend to fallback to awk when you want to print a certain column from a multiline file? And we all know you probably don’t even know `awk` very well. Or at all, except for the column filtering part. Are you that guy, or are you using the posh cut for this job? Enough with the questions. What happens is you’re not confident enough to do is to use bash for this job. And let me tell you this. Bash performs brilliantly at column splitting.

Imagine you need to print the user name and UID number for all entries in /etc/passwd. What turns you around is that you need to split each row by the colon and not the whitespace. To overcome this, use the special variable called IFS (abbreviated from Internal Field Separator) and the read built-in command.

Normally you would do:
