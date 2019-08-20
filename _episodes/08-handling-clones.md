---
title: "Handling Clones"
teaching: 5
exercises: 10
objectives:
  - Learn how GitLab CI/CD clones repositories
  - Get your submodule included/cloned
questions:
  - How are repositories cloned?
hidden: false
keypoints:
  - Git cloning strategies are configured with global (or per-job) variables
  - "`GIT_STRATEGY=none` is useful when you don't need any information/files from the repository"
  - Submodules can be cloned normally or recursively as needed
---

# Recursive cloning?

As of now, we only have a simple script that echoes `Hello World`. Presumably, we should have the repository cloned for us, but let's check.

> ## Adding `ls` commands to the CI
>
> How do we change the CI to list the directory contents (`find . -path ./.git -prune -o -print`) as well?
>
> > ## Solution
> > ~~~
> > hello world:
> >   script:
> >    - echo "Hello World"
> >    - find . -path ./.git -prune -o -print
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

If you successfully add the command, you'll get the following similar output in the CI job

~~~
Running with gitlab-runner 11.10.0 (3001a600)
  on default-runner-5f69bb6754-6qdj7 wy8q3Y5T
Using Docker executor with image gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
Pulling docker image gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
Using docker image sha256:7c63dfc66bc408978481404a95f21bbb60a9e183d5c4122a4cf29a177d3e7375 for gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
Running on runner-wy8q3Y5T-project-75375-concurrent-0 via default-runner-5f69bb6754-6qdj7...
Initialized empty Git repository in /builds/usatlas-computing-bootcamp/v6-ci-cd/.git/
Fetching changes with git depth set to 50...
Created fresh repository.
From https://gitlab.cern.ch/usatlas-computing-bootcamp/v6-ci-cd
 * [new branch]      master     -> origin/master
Checking out bb43496c as master...

Skipping Git submodules setup
$ echo "Hello World"
Hello World
$ find . -path ./.git -prune -o -print
.
./source
./source/CMakeLists.txt
./source/JetSelectionHelper
./source/AnalysisPayload
./source/AnalysisPayload/CMakeLists.txt
./source/AnalysisPayload/utils
./source/AnalysisPayload/utils/AnalysisPayload.cxx
./.gitmodules
./README.md
./.gitlab-ci.yml
Job succeeded
~~~
{: .output}

## Where are the submodules?

Looking at the output we just got, we see lines like

~~~
Skipping Git submodules setup
...
...
./source/JetSelectionHelper
(nothing else under it???)
~~~
{: .output}

which indicates that we're not cloning the submodule at all. In fact, there are a couple of (global) variables we can set to change how the repository gets cloned. Let's go over them.

# Variables

The key variables we'll discuss in today's lession are:

- `:variables:GIT_STRATEGY` (`clone`, `fetch`, `none`)
- `:variables:GIT_SUBMODULE_STATEGY` (`none`, `normal`, `recursive`)

## Controlling git strategy

You can set the `:variables:GIT_STRATEGY` used for getting recent application code, either globally or per-job in the variables section. If left unspecified, the default from project settings will be used.

There are three possible values: `clone` (default), `fetch`, and `none`.

- `clone` is the slowest option. It clones the repository from scratch for every job, ensuring that the project workspace is always pristine.
- `fetch` is faster as it re-uses the project workspace (falling back to clone if it doesn’t exist). `git clean` is used to undo any changes made by the last job, and git fetch is used to retrieve commits made since the last job ran.
- `none` also re-uses the project workspace, but skips all Git operations. It is mostly useful for jobs that operate exclusively on artifacts (e.g., deploy). You should only rely on files brought into the project workspace from cache or artifacts.

> ## Can you change the git strategy?
>
> How much faster is it to run `git fetch` versus `git clone` for CI jobs?
>
> > ## Solution
> > ~~~
> > variables:
> >  GIT_STRATEGY: fetch
> >
> > hello world:
> >   script:
> >    - echo "Hello World"
> >    - find . -path ./.git -prune -o -print
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

## Controlling git submodule strategy

The `GIT_SUBMODULE_STRATEGY` variable is used to control if / how Git submodules are included when fetching the code before a build. You can set them globally or per-job in the variables section.

There are three possible values: `none` (default), `normal`, and `recursive`:

- `none` means that submodules will not be included when fetching the project code. This is the default, which matches the pre-v1.10 behavior.
- `normal` means that only the top-level submodules will be included. It is equivalent to:
  ~~~
  git submodule sync
  git submodule update --init
  ~~~
  {: .source}
- `recursive` means that all submodules (including submodules of submodules) will be included. It is equivalent to:
  ~~~
  git submodule sync --recursive
  git submodule update --init --recursive
  ~~~
  {: .source}

> ## Git submodule URL paths
>
> For this feature to work, you need to make sure that the submodules configured in `.gitmodules` are configured with either:
> - the HTTP(S) URL of a publicly-accessible repository, or
> - a relative path to another repository on the same GitLab server.
{: .callout}

Let's get our submodule cloned! Let's try and get it working with a simple change to the variable (removing the `GIT_STRATEGY` so we keep it on default):

~~~
variables:
 GIT_SUBMODULE_STRATEGY: recursive

hello world:
  script:
   - echo "Hello World"
   - find . -path ./.git -prune -o -print
~~~
{: .language-yaml}

Did this work? The output indicates the submodule got cloned!

~~~
Running with gitlab-runner 11.10.0 (3001a600)
  on default-runner-5f69bb6754-8m5w7 tBh9XxJq
Using Docker executor with image gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
Pulling docker image gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
Using docker image sha256:7c63dfc66bc408978481404a95f21bbb60a9e183d5c4122a4cf29a177d3e7375 for gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
Running on runner-tBh9XxJq-project-75375-concurrent-0 via default-runner-5f69bb6754-8m5w7...
Initialized empty Git repository in /builds/usatlas-computing-bootcamp/v6-ci-cd/.git/
Fetching changes with git depth set to 50...
Created fresh repository.
From https://gitlab.cern.ch/usatlas-computing-bootcamp/v6-ci-cd
 * [new branch]      master     -> origin/master
Checking out e6a017a4 as master...

Updating/initializing submodules recursively...
Submodule 'JetSelectionHelper' (https://gitlab.cern.ch/usatlas-computing-bootcamp/JetSelectionHelper.git) registered for path 'source/JetSelectionHelper'
Cloning into '/builds/usatlas-computing-bootcamp/v6-ci-cd/source/JetSelectionHelper'...
Submodule path 'source/JetSelectionHelper': checked out 'ec3475f77a56b01bac015d8f5611d72adf232797'
Entering 'source/JetSelectionHelper'
$ echo "Hello World"
Hello World
$ find . -path ./.git -prune -o -print
.
./source
./source/CMakeLists.txt
./source/JetSelectionHelper
./source/JetSelectionHelper/src
./source/JetSelectionHelper/src/JetSelectionHelper.cxx
./source/JetSelectionHelper/README.md
./source/JetSelectionHelper/CMakeLists.txt
./source/JetSelectionHelper/JetSelectionHelper
./source/JetSelectionHelper/JetSelectionHelper/JetSelectionHelper.h
./source/JetSelectionHelper/.git
./source/AnalysisPayload
./source/AnalysisPayload/CMakeLists.txt
./source/AnalysisPayload/utils
./source/AnalysisPayload/utils/AnalysisPayload.cxx
./.gitmodules
./README.md
./.gitlab-ci.yml
Job succeeded
~~~
{: .output}

{% include links.md %}
