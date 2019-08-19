---
title: "YAML and CI"
teaching: 5
exercises: 5
objectives:
  - Learn where to find more details about everything for the GitLab CI.
  - Understand the structure of the GitLab CI YAML file.
questions:
  - What is the CI specification?
hidden: false
keypoints:
  - First key point. (FIXME)
---

# GitLab CI YAML

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
image: atlas/analysisbase:21.2.62

stages: [build, test, deploy]

job1:
  script: make

job2:
  image: atlas/analysisbase:21.2.72
  script: make
~~~
{: .language-yaml}

where `image` and `stages` are global parameters being used. Note that `job2:image` overrides `:image`.

## Job Parameters

What are some of the parameters that can be used in a job? Rather than copy/pasting from the reference (linked below in this session), we'll go to the [Configuration parameters](https://docs.gitlab.com/ee/ci/yaml/#configuration-parameters) section in the GitLab docs. The most important parameter, and the only one needed to define a job, is `script`

~~~
job one:
  script: make

job two:
  script:
    - pytest
    - coverage
~~~
{: .language-yaml}

> ## Understanding the Reference
>
> One will notice that the reference uses colons like `image:name` to refer to parameter names. This is represented in yaml like:
> ~~~
> job:
>   image:
>     name: atlas/analysisbase:21.2.62
> ~~~
> {: .language-yaml}
> where the colon refers to a child key.
{: .callout}

## Reference

The API for all GitLab CI/CD pipeline configurations is found at [https://docs.gitlab.com/ee/ci/yaml/](https://docs.gitlab.com/ee/ci/yaml/). This contains all the different parameters you can assign to a job.

{% include links.md %}
