---
layout: lesson
title: Introduction
root: .  # Is the only page that doesn't follow the pattern /:path/index.html
permalink: index.html  # Is the only page that doesn't follow the pattern /:path/index.html
---
{% include gh_variables.html %}

> ## Prerequisites
>
> This assumes that you'll have some basic background with your command line, for example:
>
> 1. How to execute custom shell scripts
> 2. How to run python scripts
>
> as well as having gone through all previous sessions in this workshop.
{: .prereq}

Introduction
------------

At CERN, we use GitLab to host our code. GitLab is bundled with a built-in CI/CD system that we'll learn how to develop on to make our code robust to errors, preserved, and reproducible.

The aim of this module is to:
- explore what it means to build a CI/CD workflow
- expand on concepts unique to GitLab's CI/CD which is essential to anyone working in ATLAS

> ## The skills we'll focus on:
>
> 1.  Making scripts exit correctly
> 2.  Building a CI/CD workflow of unlimited potential
> 3.  Understanding how job runners work (and get access to your clones)
> 4.  The GitLab permissions model
> 5.  Protecting secret information while allowing jobs to run
{: .checklist}

{% include curriculum.html %}

{% include links.md %}
