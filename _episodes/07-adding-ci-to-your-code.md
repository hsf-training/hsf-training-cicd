---
title: "Adding CI to Your Existing Code"
teaching: 5
exercises: 10
objectives:
  - Learn how to get your CI/CD Runners to build your code
  - Try and see if the CI/CD can catch problems with our code.
questions:
  - I have code already in GitLab, how can I add CI to it?
hidden: false
keypoints:
  - Setting up CI/CD shouldn't be mind-numbing
  - All defined jobs run in parallel by default
  - Jobs can be allowed to fail without breaking your CI/CD
---
<iframe width="420" height="263" src="https://www.youtube.com/embed/GiwtSwtMYzg?list=PLKZ9c4ONm-VmmTObyNWpz4hB3Hgx8ZWSb" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
# Time To Skim

## The Naive Attempt

As of right now, your `.gitlab-ci.yml` should look like

~~~
hello world:
  script:
   - echo "Hello World"
~~~
{: .language-yaml}

Let's go ahead and teach our CI to build our code. Let's add another job (named `build_skim`) that runs in parallel for right now, and runs the compiler `ROOT` uses. This worked for me on my computer, so we should try it:

~~~
COMPILER=$(root-config --cxx)
$COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx
~~~
{: .language-bash}

which will produce an output binary called `skim`.

> ## Adding a new job
>
> How do we change the CI in order to add a new parallel job that compiles our code?
>
> > ## Solution
> > ~~~
> > hello world:
> >   script:
> >    - echo "Hello World"
> >
> > build_skim:
> >   script:
> >    - COMPILER=$(root-config --cxx)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

![CI/CD Two Parallel Jobs]({{site.baseurl}}/fig/ci-cd-two-parallel-jobs.png)

## No root-config?

Ok, so maybe we were a little naive here. Let's start debugging. You got this error when you tried to build

~~~
Running with gitlab-runner 12.6.0 (ac8e767a)
  on default-runner-7685f6989c-bzlz8 _yp-6wmD

Using Docker executor with image gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
WARNING: Container based cache volumes creation is disabled. Will not create volume for "/cache"
Authenticating with credentials from job payload (GitLab Registry)
Pulling docker image gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...
Using docker image sha256:262a48c12b0622aabbb9331ef5f7c46b47bd100ac340ec1b076c0e83246bb573 for gitlab-registry.cern.ch/ci-tools/ci-worker:cc7 ...

Running on runner-_yp-6wmD-project-86027-concurrent-0 via default-runner-7685f6989c-bzlz8...

Fetching changes with git depth set to 50...
 Initialized empty Git repository in /builds/gstark/virtual-pipelines-eventselection/.git/
 Created fresh repository.
 From https://gitlab.cern.ch/gstark/virtual-pipelines-eventselection
  * [new ref]         refs/pipelines/1404549 -> refs/pipelines/1404549
  * [new branch]      master                 -> origin/master
 Checking out bdd593f1 as master...
 Skipping Git submodules setup

Authenticating with credentials from job payload (GitLab Registry)
 $ COMPILER=$(root-config --cxx)
 /usr/bin/bash: line 87: root-config: command not found
 ERROR: Job failed: exit code 1
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

> ## Docker???
>
> Don't panic. You do not need to understand docker to be able to use it.
{: .callout}

Let's go ahead and update our `.gitlab-ci.yml` and fix it to use a versioned docker image that has `root`: `rootproject/root:6.26.10-conda` from the [rootproject/root](https://hub.docker.com/r/rootproject/root) docker hub page.

> ## Still failed??? What the hell.
>
> What happened?
>
> > ## Answer
> > It turns out we just forgot the include flags needed for compilation. If you look at the log, you'll see
> > ~~~
> >  $ COMPILER=$(root-config --cxx)
> >  $ $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx
> >  skim.cxx:11:10: fatal error: ROOT/RDataFrame.hxx: No such file or directory
> >   #include "ROOT/RDataFrame.hxx"
> >            ^~~~~~~~~~~~~~~~~~~~~
> >  compilation terminated.
> >  ERROR: Job failed: exit code 1
> > ~~~
> > {: .output}
> > How do we fix it? We just need to add another variable to add the flags at the end via `$FLAGS` defined as `FLAGS=$(root-config --cflags --libs)`.
> {: .solution}
{: .challenge}

Ok, let's go ahead and update our `.gitlab-ci.yml` again, and it better be fixed or so help me...

# Building multiple versions

Great, so we finally got it working... CI/CD isn't obviously powerful when you're only building one thing. Let's build both the version of the code we're testing and also test that the latest ROOT image (`rootproject/root:latest`) works with our code. Call this new job `build_skim_latest`.

> ## Adding the `build_skim_latest` job
>
> What does the `.gitlab-ci.yml` look like now?
>
> > ## Solution
> > ~~~
> > hello world:
> >   script:
> >    - echo "Hello World"
> >
> > build_skim:
> >   image: rootproject/root:6.26.10-conda
> >   script:
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> >
> > build_skim_latest:
> >   image: rootproject/root:latest
> >   script:
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

However, we probably don't want our CI/CD to crash if that happens. So let's also add `:build_latest:allow_failure = true` to our job as well. This allows the job to fail without crashing the CI/CD -- that is, it's an acceptable failure. This indicates to us when we do something in the code that might potentially break the latest release; or indicate when our code will not build in a new release.

~~~
build_latest:
  image: ...
  script: [....]
  allow_failure: yes # or 'true' or 'on'
~~~
{: .language-yaml}

Finally, we want to clean up the two jobs a little by separating out the environment variables being set like `COMPILER=$(root-config --cxx)` into a `before_script` parameter since this is actually preparation for setting up our environment -- rather than part of the script we want to test! For example,

~~~
build_skim_latest:
  before_script:
   - COMPILER=$(root-config --cxx)
   - FLAGS=$(root-config --cflags --libs)
  script:
   - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
  ...
~~~
{: .language-yaml}

and we're ready for a coffee break.

> ## Building new image only on changes?
>
> Sometimes you might find that certain jobs don't need to be run when unrelated files change. For example, in this example, our job depends only on `skim.cxx`. While there is no native `Makefile`-like solution (with targets) for GitLab CI/CD (or CI/CD in general), you can emulate this with the `:job:only:changes` flag like so
> ~~~
> build_skim:
>   image: rootproject/root:6.26.10-conda
>   script:
>    - COMPILER=$(root-config --cxx)
>    - FLAGS=$(root-config --cflags --libs)
>    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
>   only:
>     changes:
>       - skim.cxx
> ~~~
> {: .language-yaml}
>
> and this will build a new image with `./skim` only if the `skim.cxx` file changes. In this case, it works since downstream jobs rely on the docker image that exists in the GitLab registry. There's plenty more one can do with this that doesn't fit in the limited time for the sessions today, so feel free to try it out on your own time.
{: .callout}


{% include links.md %}
