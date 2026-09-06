---
layout: lesson
root: .  # Is the only page that doesn't follow the pattern /:path/index.html
permalink: index.html  # Is the only page that doesn't follow the pattern /:path/index.html
---
{% include gh_variables.html %}

This learning module explores how to build CI/CD workflows and introduces key GitLab CI/CD concepts, with a focus on ensuring that code remains robust, reproducible, and well preserved.
GitLab is a git platform used for code hosting and collaboration. It can be used to automatically run checks and other code or workflows on GitLab’s servers. 

> ## Prerequisites
>
> This assumes that you'll have some basic background with your command line, for example:
>
> 1. How to execute custom shell scripts (if you are not familiar with the shell, click [here](https://swcarpentry.github.io/shell-novice/))
> 2. How to run Python scripts (if you are not familiar with Python, click [here](https://swcarpentry.github.io/python-novice-inflammation/))
> 3. How to interact with remotes in git (if you are not familiar with git, click [here](https://swcarpentry.github.io/git-novice/))
{: .prereq}

> ## Learning Objectives
>
> After completing this module, participants will be able to:
>
> - Understand the core concepts of continuous integration and continuous deployment (CI/CD). 
> - Explain how scripts and exit codes control execution in automated workflows.
> - Design and implement flexible and extendable CI/CD pipelines using GitLab.  
> - Understand how CI runners operate and interact with repository code.  
> - Apply best practices for building reusable and reproducible CI/CD pipelines.  
> - Manage GitLab permissions and securely handle sensitive information. 
{: .objectives}

{% include curriculum.html %}

{% include links.md %}
