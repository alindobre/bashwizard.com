---
layout: post
title: "Simple realtime blocking of failed login attempts"
date: 2019-04-15 12:34
comments: true
author: alindobre
---

# Simple realtime blocking of failed login attempts

I get this question a lot and notice many folks using complex scripts for a problem which is, even in enterprise environments, a simple one. How do you ban failed login attempts in an efficient way?

The idea is simple. Some daemon detects failed ssh attempts and feeds those IP addresses to a network access control system, which in turn denies the access for a while. That’s it.

## Solution features

The solution that I’m describing in this post, I thought of it while trying to solve this annoying problem. And even though it was on everyone’s lips, I found `fail2ban` far too complicated for the needs of the project I was working on. You can find ideas similar to mine by searching the Internet for the `xt_recent` keyword.

There are a few things we need to understand about this feature in general. The first of them and the most important one is you shouldn’t want to ban an IP address permanently. The IPv4 space is getting more and more crowded, so the IPs get recycled between different owners very often. An IP that last week belonged to a hacker, can now be assigned to a friend or potential customer. You don’t want to miss that opportunity. You also don’t want to ban legitimate failed attempts permanently.

Another aspect is the usefulness of this feature. There is a burden on the _Ops_ teams to try and find out useful information in an authentication log file, clogged with failed attempts. Reducing that amount benefits anyone who tries to audit or debug the login system.

From a monitoring and altering perspective, if you have an efficient system and get only, say, 95 failed attempts per hour, when you see that number going to 450, you’ll have more chances to notice that something is wrong. However, if your regular number is 4000 per hour and that number grows to 4900, you won’t necessarily see it as a problem. Of course, a good monitoring script would take care of this automatically, but that might need to be adjusted as well or its filtering complexity raised to be able to detect such thresholds.

## What do you need?

This solution, as presented here, needs:
* of course, `bash`
* the `iptables` userspace tool
* kernel support for the `xt_recent` netfilter module
* `rsyslogd` or any other logging daemon that supports feeding log lines to an external command

## The failed login firewall

I chose to use the `PREROUTING` chain of the _mangle_ table because I want to filter the banned IP addresses as soon as possible. Remember, banned IPs are consuming your kernel’s resources, so they need to consume as little as possible.

Creating a custom chain for our purpose and linking it to mangle is as simple as:
```
iptables -t mangle -N ssh-ban
iptables -t mangle -I PREROUTING -j ssh-ban
```
Again, `iptables` inserts the rule at the top of the `PREROUTING` table so it can filter these packets sooner rather than later.

### Whitelisting

You want to have a whitelist of some sort. A proper whitelist could live inside the sshd config file as `AllowUsers`. Or the `/etc/hosts.allow` file. Or somewhere in a file, but you get the idea. I’m going with listing the allowed IPs inside a file `/etc/ssh/whitelist`, one per line:
```
while read IP; do
  iptables -t mangle -A ssh-ban -p tcp -s $IP --dport 22 -j ACCEPT
done </etc/ssh/whitelist
```

### Temporary failed login ban

Finally, we add the temporary ban rule. It drops all the packets from a banned IP address for 60 seconds. That should be enough to discourage script kiddies. Whenever we want to whitelist an address, we add it at the top of the `ssh-ban` chain, so that, even if it gets to the ban list, any connection from it is accepted.
```
iptables -t mangle -A ssh-ban -m recent --rcheck --seconds 60 --name ssh-ban -p tcp --dport 22 -j DROP
```
You noticed that the ban above scans all interfaces. In real life, you only want to ban public network interfaces. Internal ones should be monitored, but not hooked into the ban system. Of course, this depends on your environment as well, adjust it as needed.

### How `xt_recent` works

The beauty of the recent module is that it’s dynamic, its logic happens in the kernel space, it’s less expensive than having to insert/delete `iptables` rules for every banned IP address. It also automatically expires the entries, so you don’t get to do too much in the userspace, other than adding IP addresses.

Now, whenever we want to ban an IP address, we add it to the `/proc/net/xt_recent/ssh-ban` virtual file. The name, `ssh-ban`, is the one that we added to the `iptables` `DROP` rule, after the `--name` argument. So this is configurable as well.

Here’s how you add an address to the ban list:
```
echo +11.22.33.44 >/proc/net/xt_recent/ssh-ban
```
If you want to unban an IP address, you can remove it from the file as well:
```
echo -11.22.33.44 >/proc/net/xt_recent/ssh-ban
```

## The failed login log handler script

Now we have to create a script that receives log lines at standard input, extracts the IP addresses and adds them to the dynamic ban list. Here’s a sample line which we want to search for:
```
22:57:30 sshd[6451]: Failed password for invalid user test from 11.22.33.44 port 40842 ssh2
```
The script is called `/bin/syslog-handler` and would look like this:
```
#!/bin/bash
shopt -s extglob
while read LINE; do
  [[ -f /proc/net/xt_recent/ssh-ban ]] || continue
  [[ $LINE == *sshd*Failed\ password\ for* ]] || continue
  read -a LOG <<<"$LINE"
  [[ ${LOG[-4]} == *.*.*.* ]] || continue
  echo +${LOG[-4]} >/proc/net/xt_recent/ssh-ban
done
```
The log line sometimes differs from when the failed login is for an existing user or not. However, the standard bit is that the IP address is the fourth field from the right. That’s what `LOG[-4]` gives us. There is an additional check to see if the string matches an IP address. `*.*.*.*` is not too much of a strict pattern, I’ll give you that, but it serves the purpose. My posts about filtering and column splitting in pure bash explain this technique in more detail.

## The rsyslog configuration

The example below is for the legacy configuration format, but if you know rsyslog, you can quickly translate that to the basic or advanced formats.
```
$ModLoad omprog
$ActionOMProgBinary /bin/syslog-handler
auth.info :omprog:
```
And with that, every line that goes through the auth logging facility on the info level is sent at the standard input of the script above.

## Solution review

Let’s review my solution with pros and cons.

Pros:
* is ridiculously simple. This is the most significant benefit you get from it
* is efficient enough. The “enough-ability” depends on each environment
* because it’s so simple, you can be further adapt it to fit more complex environments
* software needs are light – bash, along with a syslog daemon and iptables, they are all installed by default on most common Linux distros today
* even though it’s presented for failed logins over ssh, you can extend it to cover IMAP, POP, SMTP logins, but also hook it into web-based interfaces 

Cons:
* the solution isn’t distributed
* doesn’t start with a central database of IPs to be banned, although you can adjust this by adding more code
* gets reset at each reboot. Again, adjustable with a cache that survives the reboots
* isn’t efficient for distributed brute force attacks

Of course, there are more pros and cons, but these are the ones I believe are worth mentioning here.

## Hosts.deny alternative

An alternative to the `iptables` solution would be to ban those IPs through the host access control files, like `hosts.deny`. If you are considering this avenue, bear in mind that once netfilter denies an IP, that address doesn’t come up again in the log files, whereas with `hosts.deny` all attempts continue to be logged.

## Conclusion

The whole solution proves how I’m using simple bash scripting to efficiently solve a pain point that _Ops_ teams are facing nowadays. Most of the implementations I’ve done with this solution have seen a reduction of the brute force login attempts by 90%. Moreover, you can fine-tune it to be even stricter.

Here us a list of other open source solutions:
* fail2ban
* sshguard
* denyhosts


