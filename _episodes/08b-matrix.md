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



# INSERT MULTIDIMENSIONAL MATRIX USAGE HERE [FIXME]



## Variables

You might have noticed that we use `$my_os$` in the script above. If we take a look at one of the logs it shows that we have obtained the following output
```
Executing "step_script" stage of the job script 00:00
$ # INFO: Lowering limit of file descriptors for backwards compatibility. ffi: https://cern.ch/gitlab-runners-limit-file-descriptors # collapsed multi-line command
$ echo "My $my_os build"
My MacOS build
Cleaning up project directory and file based variables 00:01
Job succeeded
```
{: .output}


# DEFINE GLOBAL VARIABLES HERE [FIXME]


In other words, we can access the values from the variable `my_os` and do something with it! This is very handy as you will see.

Let's now mix the usage of multiple jobs and the the fact that we can exctrat values from variables we defined in the code we have been using since the last episode.
