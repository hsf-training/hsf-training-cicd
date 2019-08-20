---
title: "Run Analysis in CI/CD"
teaching: 5
exercises: 25
objectives:
  -
questions:
  - How can I run my code in the CI/CD?
hidden: false
keypoints:
  - First key point. (FIXME)
---

# The Naive Attempt

Let's just attempt to try and get the code working as it is. Since it worked for us already locally, surely the CI/CD must be able to run it??? As a reminder of what we've ended with from the last session:

~~~
stages:
  - greeting
  - build

variables:
  GIT_SUBMODULE_STRATEGY: recursive

hello world:
  stage: greeting
  script:
    - echo "Hello World"
    - find . -path ./.git -prune -o -print

.build_template:
  stage: build
  before_script:
    - source /home/atlas/release_setup.sh
  script:
    - mkdir build
    - cd build
    - cmake ../source
    - cmake --build .

build:
  extends: .build_template
  image: atlas/analysisbase:21.2.85-centos7

build_latest:
  extends: .build_template
  image: atlas/analysisbase:latest
  allow_failure: yes
~~~
{: .language-yaml}

So we need to do two things:

1. add a `test` stage
2. add a `test` job

Let's go ahead and do that, so we now have three stages

~~~
stages:
  - greeting
  - build
  - test
~~~
{: .language-yaml}

and we just need to figure out how to define a test job. Since the code is built, the script needs to source the `${AnalysisBase_PLATFORM}/setup.sh` script, create a `run` directory, and run the `AnalysisPayload` utility we compiled from our code. Seems too easy to be true?

~~~
test:
  stage: test
  image: atlas/analysisbase:21.2.85-centos7
  before_script:
    - source /home/atlas/release_setup.sh
    - source build/${AnalysisBase_PLATFORM}/setup.sh
  script:
    - mkdir run
    - cd run
    - AnalysisPayload
~~~
{: .language-yaml}

~~~
$ source build/${AnalysisBase_PLATFORM}/setup.sh
/usr/bin/bash: line 81: build/x86_64-centos7-gcc8-opt/setup.sh: No such file or directory
ERROR: Job failed: exit code 1
~~~
{: .output}

# We're too naive

Ok, fine. That was way too easy. It seems we have a few issues to deal with.

1. The built code in the `build` job (of the `build` stage) isn't in the `test` job by default. We need to use GitLab `artifacts` to copy over this from the right job (and not from `build_latest`).
2. The data (ROOT file) isn't available to the Runner yet.

## Artifacts

`artifacts` is used to specify a list of files and directories which should be attached to the job when it succeeds, fails, or always. The artifacts will be sent to GitLab after the job finishes and will be available for download in the GitLab UI.

> ## More Reading
> - [https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html](https://docs.gitlab.com/ee/user/project/pipelines/job_artifacts.html)
{: .checklist}

> ## Default Behavior
>
> Artifacts from all previous stages are passed in by default.
{: .callout}

Artifacts are the way to transfer files between jobs of different stages. In order to take advantage of this, one combines `artifacts` with `dependencies`.

> ## Using Dependencies
>
> To use this feature, define `dependencies` in context of the job and pass a list of all previous jobs from which the artifacts should be downloaded. You can only define jobs from stages that are executed before the current one. An error will be shown if you define jobs from the current stage or next ones. Defining an empty array will skip downloading any artifacts for that job. The status of the previous job is not considered when using `dependencies`, so if it failed or it is a manual job that was not run, no error occurs.
{: .callout}

> ## Don't want to use dependencies?
>
> Adding `dependencies: []` will prevent downloading any artifacts into that job. Useful if you want to speed up jobs that don't need the artifacts from previous stages!
{: .callout}

Ok, so what can we define with `artifacts`?

- `artifacts:paths`: wild-carding works (but not often suggested)
- `artifacts:name`: name of the archive when downloading from the UI (default: `artifacts ->  artifacts.zip`)
- `artifacts:untracked`: boolean flag indicating whether to add all Git untracked files or not
- `artifacts:when`: when to upload artifacts; `on_success` (default), `on_failure`, or `always`
- `artifacts:expire_in`: human-readable length of time (default: `30 days`) such as `3 mins 14 seconds`
- `artifacts:reports` (JUnit tests - expert-mode, will not cover)


{% include links.md %}
