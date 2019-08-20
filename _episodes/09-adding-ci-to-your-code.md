---
title: "Adding CI to Your Existing Code"
teaching: 5
exercises: 5
objectives:
  - Learn how to get your CI/CD Runners to build your code
  - Try and see if the CI/CD can catch problems with our code.
questions:
  - I have code already in GitLab, how can I add CI to it?
hidden: false
keypoints:
  - First key point. (FIXME)
---

# CMake Revisited

## The Naive Attempt

As of right now, your `.gitlab-ci.yml` should look like

~~~
variables:
 GIT_SUBMODULE_STRATEGY: recursive

hello world:
  script:
   - echo "Hello World"
   - find . -path ./.git -prune -o -print
~~~
{: .language-yaml}

Let's go ahead and teach our CI to build our code. Let's add another job (named `build`) that runs in parallel for right now, and runs `cmake` and `make`. Don't forget that we also need to make a `build` directory, and that we would like to do an **out-of-source** build.

> ## Adding a new job
>
> How do we change the CI in order to add a new parallel job that compiles our code?
>
> > ## Solution
> > ~~~
> > variables:
> >   GIT_SUBMODULE_STRATEGY: recursive
> >
> > hello world:
> >   script:
> >    - echo "Hello World"
> >    - find . -path ./.git -prune -o -print
> >
> > build:
> >   script:
> >    - mkdir build
> >    - cd build
> >    - cmake ../source
> >    - cmake --build .
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

![CI/CD Two Parallel Jobs]({{site.baseurl}}/fig/ci-cd-two-parallel-jobs.png)

## Wrong CMake?

Ok, so maybe we were a little naive here. Let's start debugging. You got this error when you tried to build

~~~
$ cmake ../source
-- The C compiler identification is GNU 4.8.5
-- The CXX compiler identification is unknown
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
CMake Error: your CXX compiler: "CMAKE_CXX_COMPILER-NOTFOUND" was not found.   Please set CMAKE_CXX_COMPILER to a valid compiler path or name.
CMake Error at CMakeLists.txt:6 (cmake_minimum_required):
  CMake 3.4 or higher is required.  You are running version 2.8.12.2


-- Configuring incomplete, errors occurred!
See also "/builds/usatlas-computing-bootcamp/v6-ci-cd/build/CMakeFiles/CMakeOutput.log".
See also "/builds/usatlas-computing-bootcamp/v6-ci-cd/build/CMakeFiles/CMakeError.log".
~~~
{: .output}

> ## Broken Build
>
> What happened?
>
> > ## Answer
> > It turns out we had the wrong docker image for our build. If you look at the log, you'll see
> > ~~~
> > Pulling docker image gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
> > Using docker image sha256:7c63dfc66bc408978481404a95f21bbb60a9e183d5c4122a4cf29a177d3e7375 for gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
> > ~~~
> > {: .output}
> > How do we fix it? We need to define the image as either a global parameter (`:image`) or as a per-job parameter (`:build:image`). Since we already have another job that doesn't need this image (and we don't want to introduce a regression), it's best practice to define the image we use on a per-job basis.
> {: .solution}
{: .challenge}

Let's go ahead and update our `.gitlab-ci.yml` and fix it.

> ## Still the wrong cmake???
>
> What happened?
>
> > ## Answer
> > It turns out we just forgot to source `/home/atlas/release_setup.sh`.
> {: .solution}
{: .challenge}

Ok, let's go ahead and update our `.gitlab-ci.yml` again, and it better be fixed or so help me...

{% include links.md %}
