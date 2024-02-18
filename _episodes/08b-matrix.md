---
title: "Even more builds"
teaching: 10
exercises: 5
objectives:
  - Matrix workflows
  - Making reusable/flexible CI/CD jobs
questions:
  - How can we make variations of our builds?
hidden: false
keypoints:
  - Matrices can help make many builds with variations
  - Use Variables whenever it's convenient
---


# Parallel and  Matrix jobs

Matrices are one of the fundamental concepts of CIs. They allow for flexible workflows that involve building or running scripts with many variations in a few lines. In Gitlab, we need to use the `parallel` keyword to run a job multiple times in parallel in a single pipeline.

This example creates 5 jobs that run in parallel, named `test 1/5` to `test 5/5`.

```yml
test:
  script: echo "multiple jobs"
  parallel: 5
```

![Parallel jobs running]({{site.baseurl}}/fig/parallel-example.png){:width="60%"}

A pipeline with jobs that use parallel might:

- Create more jobs running in parallel than available runners. Excess jobs are queued and marked pending while waiting for an available runner.
- Create too many jobs, and the pipeline fails with a `job_activity_limit_exceeded` error. The maximum number of jobs that can exist in active pipelines is [limited at the instance-level](https://docs.gitlab.com/ee/administration/instance_limits.html#number-of-jobs-in-active-pipelines).


## Matrices

It's not really useful to simply repeat the same exact job, it is far more useful if each job can be different.
Use `parallel:matrix` to run a job multiple times in parallel in a single pipeline, but with different variable values for each instance of the job. Some conditions on the possible inputs are:
- The variable names can use only numbers, letters, and underscores `_`.
- The values must be either a string, or an array of strings.
- The number of permutations cannot exceed 200.

In order to make use of `parallel:matrix` let's give a list of dictionaries that simulate a build running on Windows, Linux or MacOS.
<!-- and installing some package we need with 2 versions. Let's define two variables `$OS` and `$package-version`. -->


```yml
test_build:

  script:
    - echo "My $my_os build"
  parallel:
    matrix:
      - my_os: [Windows,Linux,MacOS]

```

![Parallel OS builds]({{site.baseurl}}/fig/parallel-os.png){: width="60%"}


We can create multiple versions of the build by giving more options. Let's add a `version` and give it a list of 2 numbers.

```yml
test_build:

  script:
    - echo "My $my_os build"
  parallel:
    matrix:
      - my_os: [Windows,Linux,MacOS]
        version: ["12.0","14.2"]
```

![Parallel OS with versions]({{site.baseurl}}/fig/parallel-versions.png){: width="60%"}


If you want to specify different OS and version pairs you can do that as well.
```yml
test_build:
  script:
    - echo "My $my_os build"
  parallel:
    matrix:
      - my_os: Windows
        version: ["10","11"]
      - my_os: Linux
        version: "Ubuntu-22.04LTS"
      - my_os: MacOS
        version: ["Sonoma","Ventura"]
```

![Specified OS and version pairs]({{site.baseurl}}/fig/parallel-specified.png){: width="60%"}


## Variables

You might have noticed that we use `$my_os` in the script above. If we take a look at one of the logs it shows that we have obtained the following output
```
Executing "step_script" stage of the job script 00:00
$ # INFO: Lowering limit of file descriptors for backwards compatibility. ffi: https://cern.ch/gitlab-runners-limit-file-descriptors # collapsed multi-line command
$ echo "My $my_os build"
My MacOS build
Cleaning up project directory and file based variables 00:01
Job succeeded
```
{: .output}


What this means is that we can access the values from the variable `my_os` and do something with it! This is very handy as you will see. Not only can we access values from the yml but we can create global variables that remain constant for the entire process.

> ## Example
> ```yml
> variables:
>   global_var: "My global variable"
>
> test_build:
>   variables:
>     my_local_var: "My local World"
>   script:
>     - echo "Hello $my_var"
>     - echo "Hello $global_var"
>     - echo "My $my_os build version $version"
>   parallel:
>     matrix:
>       - my_os: Windows
>         version: ["10","11"]
>       - my_os: Linux
>         version: "Ubuntu-22.04LTS"
>       - my_os: MacOS
>         version: ["Sonoma","Ventura"]
> ```
{: .callout}


# Mix it all up and write less code!

Let's now mix the usage of parallel jobs and the the fact that we can exctrat values from variables we defined.
Let's try implementing this with the config file we've been developing so far.

> ## Remember what we have so far
> ```yml
> hello_world:
>   script:
>     - echo "Hello World"
>
> .template_build:
>   before_script:
>     - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
>     - bash ~/miniconda.sh -b -p $HOME/miniconda
>     - eval "$(~/miniconda/bin/conda shell.bash hook)"
>     - conda init
>
>
> build_skim:
>   extends: .template_build
>   script:
>    - conda install root=6.28 --yes
>    - COMPILER=$(root-config --cxx)
>    - FLAGS=$(root-config --cflags --libs)
>    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
>
>
> build_skim_latest:
>   extends: .template_build
>   script:
>    - conda install root --yes
>    - COMPILER=$(root-config --cxx)
>    - FLAGS=$(root-config --cflags --libs)
>    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
>   allow_failure: yes
>
> ```
{: .solution}

Now let's apply what we learned to refactor and reduce the code all into a single job named `multi_build`.

```yml
hello_world:
  script:
    - echo "Hello World"

multi_build:
  before_script:
    - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
    - bash ~/miniconda.sh -b -p $HOME/miniconda
    - eval "$(~/miniconda/bin/conda shell.bash hook)"
    - conda init
    - conda install $ROOT_VERS --yes
    - COMPILER=$(root-config --cxx)
    - FLAGS=$(root-config --cflags --libs)
  script:
    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
  parallel:
    matrix:
      - ROOT_VERS: ["root=6.28","root"]
```


> ## Note
> 1. We have only defined a `ROOT_VERS` list and we use this in the `before_script` section to setup the intalation of ROOT.  After testing it we can see that this works and we've been able to reduce the amount of text a lot more.
> 2. We have dropped the `allow_failure: yes`.
{: .callout}
