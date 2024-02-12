---
title: "YAML and CI"
teaching: 5
exercises: 0
objectives:
  - Learn where to find more details about everything for the GitLab CI.
  - Understand the structure of the GitLab CI YAML file.
questions:
  - What is the GitLab CI specification?
hidden: false
keypoints:
  - You should bookmark the GitLab reference on CI/CD. You'll visit that page often.
  - A job is defined by a name and a script, at minimum.
  - Other than job names, reserved keywords are the top-level parameters defined in a YAML file.
---
<iframe width="420" height="263" src="https://www.youtube.com/embed/1Kz3VrzYHb0?list=PLKZ9c4ONm-VmmTObyNWpz4hB3Hgx8ZWSb" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
# GitLab CI YAML

The GitLab CI configurations are specified using a YAML file called `.gitlab-ci.yml`. Here is an example:

~~~
stages:
  - build

job_1:
  stage: build
  script:
    - echo "This is the first step of my first job"
~~~
{: .language-yaml}

This is a minimal example used to introduce the basic structure of a GitLab CI/CD pipeline. The provided YAML configuration sets up a single-stage pipeline with one job named job_1. Let's break down the key components:

 - The `stages` section defines the different stages in the pipeline. In this example, there is a single stage named `build`.

 - The `job_1` section specifies a job within the `build` stage. The `script` section contains the commands to be executed as part of the job. In this case, the job simply prints the message "This is the first step of my first job."

This YAML configuration represents a basic GitLab CI/CD pipeline with one stage (`build`) and one job (`job_1`). The job executes a simple script that echoes a message to the console. In more complex scenarios, jobs can include various tasks such as building, testing, and deploying code. Understanding this foundational structure is essential for creating more advanced and customized CI/CD pipelines in GitLab.


> ## `script` commands
>
> Sometimes, `script` commands will need to be wrapped in single or double quotes. For example, commands that contain a colon (`:`) need to be wrapped in quotes so that the YAML parser knows to interpret the whole thing as a string rather than a “key: value” pair. Be careful when using special characters: `:`, `{`, `}`, `[`, `]`, `,`, `&`, `*`, `#`, `?`, `|`, `-`, `<`, `>`, `=`, `!`, `%`, `@`, `\``.
{: .callout}

This is the simplest possible configuration that will work for most code using minimal dependencies with `cmake` and `make`:

1. Define one job `build_code` (the job names are arbitrary) with different commands to be executed.
2. Before every job, the commands defined by `before_script` are executed.

The `.gitlab-ci.yml` file defines sets of jobs with constraints of how and when they should be run. The jobs are defined as top-level elements with a name (in our case `build_code`) and always have to contain the `script` keyword. Let's explore this structure in more depth.

## Overall Structure

Every single parameter we consider for all configurations are keys under jobs. The YAML is structured using job names. For example, we can define three jobs that run in parallel (more on parallel/serial later) with different sets of parameters.

~~~
job1:
  param1: null
  param2: null

job2:
  param1: null
  param3: null

job3:
  param2: null
  param4: null
  param5: null
~~~
{: .language-yaml}

> ## Parallel or Serial Execution?
>
> Note that by default, all jobs you define run in parallel. If you want them to run in serial, or a mix of parallel and serial, or as a directed acyclic graph, we'll cover this in a later section.
{: .callout}

What can you not use as job names? There are a few reserved keywords (because these are used as global parameters for configuration, in addition to being job-specific parameters):

- `default`
- `image`
- `services`
- `stages`
- `types`
- `before_script`
- `after_script`
- `variables`
- `cache`

Global parameters mean that you can set parameters at the top-level of the YAML file. What does that actually mean? Here's another example:

~~~
stages: [build, test, deploy]

<workflow_name>:
  stage: build
  script:
    - echo "This is the script for the workflow."

job_1:
  stage: test
  script:
    - echo "Commands for the first job - Step 1"
    - echo "Commands for the first job - Step 2"

job_2:
  stage: test
  script:
    - echo "Commands for the second job - Step 1"
    - echo "Commands for the second job - Step 2"

~~~
{: .language-yaml}

where `stages` is the global parameter being used.


> ## Stages???
>
> Ok, ok, yes, there are also stages. You can think of it like putting on a show. A pipeline is composed of stages. Stages are composed of jobs. All jobs in a stage perform at the same time, run in parallel. You can only perform on one stage at a time, like in broadway. We'll cover stages and serial/parallel execution in a later lesson when we add more complexity to our CI/CD.
>
> Additionally, note that all jobs are defined with a default (unnamed) stage unless explicitly specified. Therefore, all jobs you define will run in parallel by default. When you care about execution order (such as building before you test), then we need to consider multiple stages and job dependencies.
{: .callout}
where `stages` is the global parameter being used.

## Job Parameters

What are some of the parameters that can be used in a job? Rather than copy/pasting from the reference (linked below in this session), we'll go to the [Configuration parameters](https://docs.gitlab.com/ee/ci/yaml/#configuration-parameters) section in the GitLab docs. The most important parameter, and the only one needed to define a job, is `script`

~~~
job one:
  script: make

job two:
  script:
    - python test.py
    - coverage
~~~
{: .language-yaml}

> ## Understanding the Reference
>
> One will notice that the reference uses colons like `:job:image:name` to refer to parameter names. This is represented in yaml like:
> ~~~
> job:
>   image:
>     name: rikorose/gcc-cmake:gcc-6
> ~~~
> {: .language-yaml}
> where the colon refers to a child key.
{: .callout}

## Documentation

The reference guide for all GitLab CI/CD pipeline configurations is found at [https://docs.gitlab.com/ee/ci/yaml/](https://docs.gitlab.com/ee/ci/yaml/). This contains all the different parameters you can assign to a job.


{% include links.md %}
