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
Running with gitlab-runner 16.7.1 (3eda8038)

on runners-k8s-default-runners-699db8b9cc-7l4sv cMz2L-3y, system ID: r_fWkCk3SCPl9H

feature flags: FF_USE_ADVANCED_POD_SPEC_CONFIGURATION:true

Resolving secrets 00:00

Preparing the "kubernetes" executor 00:00

Using Kubernetes namespace: gitlab

Using Kubernetes executor with image gitlab-registry.cern.ch/linuxsupport/rpmci/builder-al9:latest ...

Using attach strategy to execute scripts...

Preparing environment 00:07

Using FF_USE_POD_ACTIVE_DEADLINE_SECONDS, the Pod activeDeadlineSeconds will be set to the job timeout: 1h0m0s...

WARNING: Advanced Pod Spec configuration enabled, merging the provided PodSpec to the generated one. This is an alpha feature and is subject to change. Feedback is collected in this issue: https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29659 ...

Waiting for pod gitlab/runner-cmz2l-3y-project-178677-concurrent-1-0xkse5cc to be running, status is Pending

Waiting for pod gitlab/runner-cmz2l-3y-project-178677-concurrent-1-0xkse5cc to be running, status is Pending

ContainersNotReady: "containers with unready status: [build helper]"

ContainersNotReady: "containers with unready status: [build helper]"

Running on runner-cmz2l-3y-project-178677-concurrent-1-0xkse5cc via runners-k8s-default-runners-699db8b9cc-7l4sv...

Getting source from Git repository 00:01

Fetching changes with git depth set to 20...

Initialized empty Git repository in /builds/sharmari/virtual-pipelines-eventselection/.git/

Created fresh repository.

Checking out a38a66ae as detached HEAD (ref is master)...

Skipping Git submodules setup

Executing "step_script" stage of the job script 00:00

$ # INFO: Lowering limit of file descriptors for backwards compatibility. ffi: https://cern.ch/gitlab-runners-limit-file-descriptors # collapsed multi-line command

$ COMPILER=$(root-config --cxx)

/scripts-178677-36000934/step_script: line 152: root-config: command not found

Cleaning up project directory and file based variables 00:01

ERROR: Job failed: command terminated with exit code 1

~~~
{: .output}

> ## Broken Build
>
> What happened?
>
> > ## Answer
> > It turns out we didn't have ROOT installed.
> > How do we fix it? We need to download and install the miniforge installer. The -b -p options specify a batch mode installation without user interaction, and the installation path is set to $HOME/miniconda. Setup the conda environment and initialize conda. Then install ROOT with conda and verify the installation with a python script.
> > ## Solution
> > ~~~
> > hello_world:
> >   script:
> >     - echo "Hello World"
> > build_skim:
> >   script:
> >     - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
> >     - bash ~/miniconda.sh -b -p $HOME/miniconda
> >     - eval "$(~/miniconda/bin/conda shell.bash hook)"
> >     - conda init
> >     - conda install root
> >     - python -c "import ROOT; print(ROOT.__version__); print(ROOT.TH1F('meow', '', 10, -5, 5))"
> >     - COMPILER=$(root-config --cxx)
> >     - FLAGS=$(root-config --cflags --libs)
> >     - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> > ~~~
> {: .solution}
{: .challenge}


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
