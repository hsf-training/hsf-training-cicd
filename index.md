---
layout: lesson
root: .  # Is the only page that doesn't follow the pattern /:path/index.html
permalink: index.html  # Is the only page that doesn't follow the pattern /:path/index.html
---
{% include gh_variables.html %}

GitLab is a git platform used for code hosting and collaboration. It can be used to automatically run checks and other code or workflows on GitLab’s servers. We’ll learn how to use this to make our code robust to errors, preserved, and reproducible.

> ## The skills we'll focus on:
>
> 1.  Making scripts exit correctly
> 2.  Building a CI/CD workflow of unlimited potential
> 3.  Understanding how job runners work (and get access to your clones)
> 4.  The GitLab permissions model
> 5.  Protecting secret information while allowing jobs to run
{: .checklist}


> ## Prerequisites
>
> This assumes that you'll have some basic background with your command line, for example:
>
> 1. How to execute custom shell scripts (if you are not familiar with the shell, click [here](https://swcarpentry.github.io/shell-novice/))
> 2. How to run python scripts (if you are not familiar with python, click [here](https://swcarpentry.github.io/python-novice-inflammation/))
> 3. How to interact with remotes in git (if you are not familiar with git, click [here](https://swcarpentry.github.io/git-novice/))
{: .prereq}

{% include curriculum.html %}

{% include links.md %}
