---
title: "Exit (light) Codes"
teaching: 10
exercises: 10
objectives:
  - Understand exit codes
  - How to print exit codes
  - How to set exit codes in a script
  - How to ignore exit codes
  - Create a script that terminates in success/error
questions:
  - What is an exit code?
hidden: false
keypoints:
  - Exit codes are used to identify if a command or script executed with errors or not
  - Not everyone respects exit codes

---

As we enter the first episode of the Continuous Integration / Continuous Deployment (CI/CD) session, we learn how to exit.

<iframe width="420" height="263" src="https://www.youtube.com/embed/NpJcaQPvLC0?list=PLKZ9c4ONm-VmmTObyNWpz4hB3Hgx8ZWSb" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
# Start by Exiting

How does a general task know whether or not a script finished correctly or not? You could parse (`grep`) the output:

~~~
> ls nonexistent-file
~~~
{: .language-bash}

~~~
ls: cannot access 'nonexistent-file': No such file or directory
~~~
{: .output}

But every command outputs something differently. Instead, scripts also have an (invisible) exit code:

~~~
> ls nonexistent-file
> echo $?
~~~
{: .language-bash}

~~~
ls: cannot access 'nonexistent-file': No such file or directory
2
~~~
{: .language-bash}

The exit code is `2` indicating failure. What about on success? The exit code is `0` like so:

~~~
> echo
> echo $?
~~~
{: .language-bash}

~~~

0
~~~
{: .output}

But this works for any command you run on the command line! For example, if I mistyped `git status`:

~~~
> git stauts
> echo $?
~~~
{: .language-bash}

~~~
git: 'stauts' is not a git command. See 'git --help'.

The most similar command is
  status
1
~~~
{: .output}

and there, the exit code is non-zero -- a failure.

> ## Exit Code is not a Boolean
>
> You've probably trained your intuition to think of `0` as falsy. However, exit code of `0` means there was no error. If you feel queasy about remembering this, imagine that the question asked is "Was there an error in executing the command?" `0` means "no" and non-zero (`1`, `2`, ...) means "yes".
{: .callout}

Try out some other commands on your system, and see what things look like.

# Printing Exit Codes

As you've seen above, the exit code from the last executed command is stored in the `$?` environment variable. Accessing from a shell is easy `echo $?`. What about from python? There are many different ways depending on which library you use. Using similar examples above, we can use the (note: deprecated) `os.system` call:

> ## Snake Charming
>
> To enter the Python interpreter, simply type `python` in your command line.
>
> Once inside the Python interpreter, simply type `exit()` then press enter, to exit.
{: .callout}

~~~
>>> import os,subprocess
>>> ret = os.system('ls')
>>> os.WEXITSTATUS(ret)
0
>>> ret = os.system('ls nonexistent-file')
>>> os.WEXITSTATUS(ret)
1
~~~
{: .language-python}

One will note that this returned a different exit code than from the command line (indicating there's some internal implementation in Python). All you need to be concerned with is that the exit code was non-zero (there was an error).

# Setting Exit Codes

So now that we can get those exit codes, how can we set them? Let's explore this in `shell` and in `python`.

## Shell

Create a file called `bash_exit.sh` with the following content:

~~~
#!/usr/bin/env bash

if [ $1 == "hello" ]
then
  exit 0
else
  exit 59
fi
~~~
{: .language-bash}

and then make it executable `chmod +x bash_exit.sh`. Now, try running it with `./bash_exit.sh hello` and `./bash_exit.sh goodbye` and see what those exit codes are.

## Python

Create a file called `python_exit.py` with the following content:

~~~
#!/usr/bin/env python

import sys
if sys.argv[1] == "hello":
  sys.exit(0)
else:
  sys.exit(59)
~~~
{: .language-python}

and then make it executable `chmod +x python_exit.py`. Now, try running it with `./python_exit.py hello` and `./python_exit.py goodbye` and see what those exit codes are. Déjà vu?

# Ignoring Exit Codes

To finish up this section, one thing you'll notice sometimes (in ATLAS or CMS) is that a script you run doesn't seem to respect exit codes. A notable example in ATLAS is the use of `setupATLAS` which returns non-zero exit status codes even though it runs successfully! This can be very annoying when you start development with the assumption that exit status codes are meaningful (such as with CI). In these cases, you'll need to ignore the exit code. An easy way to do this is to execute a second command that always gives `exit 0` if the first command doesn't, like so:

~~~
> :(){ return 1; };: || echo ignore failure
~~~
{: .language-bash}

The `command_1 || command_2` operator means to execute `command_2` only if `command_1` has failed (non-zero exit code). Similarly, the `command_1 && command_2` operator means to execute `command_2` only if `command_1` has succeeded. Try this out using one of scripts you made in the previous session:

~~~
> ./python_exit.py goodbye || echo ignore
~~~
{: .language-bash}

What does that give you?

> ## Overriding Exit Codes
>
> It's not really recommended to 'hack' the exit codes like this, but this example is provided so that you are aware of how to do it, if you ever run into this situation. Assume that scripts respect exit codes, until you run into one that does not.
{: .callout}

{% include links.md %}
