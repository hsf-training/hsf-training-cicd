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
> Initialized empty Git repository in /builds/sharmari/virtual-pipelines-eventselection/.git/
>
> Created fresh repository.
>
> Checking out a38a66ae as detached HEAD (ref is master)...
>
> Skipping Git submodules setup
>
> Executing "step_script" stage of the job script 00:00
>
> $ # INFO: Lowering limit of file descriptors for backwards compatibility. ffi: https://cern.ch/gitlab-runners-limit-file-descriptors # collapsed multi-line command
>
> $ COMPILER=$(root-config --cxx)
>
> /scripts-178677-36000934/step_script: line 152: root-config: command not found
>
> Cleaning up project directory and file based variables 00:01
>
> ERROR: Job failed: command terminated with exit code 1
> ```
> {: .output}
{: .solution}

 We have a broken build. What happened?

> ## Answer
>  It turns out we didn't have ROOT installed.
>  How do we fix it? We need to download and install the miniforge installer. The `-b -p` options specify a batch mode installation without user interaction, and the installation path is set to `$HOME/miniconda`. Setup the conda environment and initialize conda. Then install ROOT with conda and verify the installation with a python script.
>
> ```yml
> hello_world:
>   script:
>     - echo "Hello World"
> build_skim:
>   script:
>     - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
>     - bash ~/miniconda.sh -b -p $HOME/miniconda
>     - eval "$(~/miniconda/bin/conda shell.bash hook)"
>     - conda init
>     - conda install root
>     - COMPILER=$(root-config --cxx)
>     - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx
> ```
{: .solution}


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

Ok, let's go ahead and update our `.gitlab-ci.yml` again. It works!

# Building multiple versions

Great, so we finally got it working... CI/CD isn't obviously powerful when you're only building one thing. Let's build the code both with the latest ROOT image and also with a specific root version. Let's name the two jobs `build_skim` and `build_skim_latest`.

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
> >  script:
> >    - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
> >    - bash ~/miniconda.sh -b -p $HOME/miniconda
> >    - eval "$(~/miniconda/bin/conda shell.bash hook)"
> >    - conda init
> >    - conda install root=6.28 --yes
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> >
> > build_skim_latest:
> >  script:
> >    - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
> >    - bash ~/miniconda.sh -b -p $HOME/miniconda
> >    - eval "$(~/miniconda/bin/conda shell.bash hook)"
> >    - conda init
> >    - conda install root --yes
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

However, we probably don't want our CI/CD to crash if one of the jobs fails. So let's also add `:build_skim_latest:allow_failure = true` to our job as well. This allows the job to fail without crashing the CI/CD -- that is, it's an acceptable failure. This indicates to us when we do something in the code that might potentially break the latest release; or indicate when our code will not build in a new release.

~~~
build_skim_latest:

  script: [....]
  allow_failure: true
~~~
{: .language-yaml}

Finally, we want to clean up the two jobs a little by separating out the  miniconda download into a `before_script` and initialization  since this is actually preparation for setting up our environment -- rather than part of the script we want to test! For example,

~~~
build_skim_latest:
  before_script:
   - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
   - bash ~/miniconda.sh -b -p $HOME/miniconda
   - eval "$(~/miniconda/bin/conda shell.bash hook)"
   - conda init

  script:
   - conda install root --yes
   - COMPILER=$(root-config --cxx)
   - FLAGS=$(root-config --cflags --libs)
   - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS

~~~
{: .language-yaml}

and we're ready for a coffee break.

> ## Building new image only on changes?
>
> Sometimes you might find that certain jobs don't need to be run when unrelated files change. For example, in this example, our job depends only on `skim.cxx`. While there is no native `Makefile`-like solution (with targets) for GitLab CI/CD (or CI/CD in general), you can emulate this with the `:job:only:changes` flag like so
> ~~~
> build_skim:
>   before_script:
>    - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
>    - bash ~/miniconda.sh -b -p $HOME/miniconda
>    - eval "$(~/miniconda/bin/conda shell.bash hook)"
>    - conda init
>   script:
>    - conda install root=6.28 --yes
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
