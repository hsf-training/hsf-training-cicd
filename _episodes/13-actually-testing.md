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
  - Making code that is both human-friendly and computer-friendly is not so obvious.
  - Configurability is the crux of reproducibility.
  - Sometimes code that we thought was working fine, could use some "freshening" up.
  - We're way too naive.
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

1. add a `run` stage
2. add a `run_exotics` job

Let's go ahead and do that, so we now have three stages

~~~
stages:
  - greeting
  - build
  - run
~~~
{: .language-yaml}

and we just need to figure out how to define a run job. Since the code is built, the script needs to source the `${AnalysisBase_PLATFORM}/setup.sh` script, create a `run` directory, and run the `AnalysisPayload` utility we compiled from our code. Seems too easy to be true?

~~~
run_exotics:
  stage: run
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

1. The built code in the `build` job (of the `build` stage) isn't in the `run_exotics` job by default. We need to use GitLab `artifacts` to copy over this from the right job (and not from `build_latest`).
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

Since the build artifacts don't need to exist for more than a day, let's add artifacts to our jobs in `build` that `expire_in = 1 day`.

> ### Adding Artifacts
>
> Let's add `artifacts` to our jobs to save the `build/` directory. We'll also make sure the `run_exotics` job has the right `dependencies` as well.
>
> > ## Solution
> > ~~~
> > ...
> > ...
> > .build_template:
> >   stage: build
> >   before_script:
> >     - source /home/atlas/release_setup.sh
> >   script:
> >     - mkdir build
> >     - cd build
> >     - cmake ../source
> >     - cmake --build .
> >   artifacts:
> >     paths:
> >       - build
> >     expire_in: 1 day
> > ...
> > ...
> > run_exotics:
> >   stage: run
> >   image: atlas/analysisbase:21.2.85-centos7
> >   dependencies:
> >     - build
> >   before_script:
> >     - source /home/atlas/release_setup.sh
> >     - source build/${AnalysisBase_PLATFORM}/setup.sh
> >   script:
> >     - mkdir run
> >     - cd run
> >     - AnalysisPayload
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

Ok, it looks like the CI passed unexpectedly. In fact, it seems we've uncovered an unknown feature of `event.readFrom` where passing in a nullptr doesn't cause the code to error out! We'll deal with that as well.

## Getting Data

So now we've dealt with the first problem of getting the built code available to the `run_exotics` job via `artifacts` and `dependencies`. Now we need to think about how to get the data in. We could:

- `wget` the entire ROOT file every time
- `git commit` the ROOT file into the repo
  - ok, maybe not our repo, but another repo that you can add as a submodule so you don't have to clone it every time
- fine, maybe we can make a smaller ROOT file
- what? we don't have time to cover that? ok, can we use `xrdcp`?
- yes, I realize it's a big ROOT file but still...

Anyway, there's lots of options. For large (ROOT) files, it's usually preferable to either

- stream the file event-by-event (or chunks of events at a time) and only process a small number of events
- download a small file that you process entirely

The first option is going to be much easier to deal with, so let's try and edit our code to allow for command-line arguments, and fix the `event.readFrom` bug at the same time.

### Fixing the bug

We only need one more line of code to fix the bug:

~~~
xAOD::TEvent event;
std::unique_ptr< TFile > iFile ( TFile::Open(inputFilePath, "READ") );
if(!iFile) return 1;
event.readFrom( iFile.get() );
~~~
{: .language-c++}

Why does this work? Because the exit code is the return value of the `main()` function! Make the changes, compile, and try it out yourself by running `AnalysisPayload` without the data file locally and then checking the exit code.

### Hardcoded data paths

The first thing is we need to deal with the hard-coded data path. We shouldn't try and keep backwards-compatibility. This is easier than you think with a few tweaks!

We need to change the signature of `main` to accept command-line arguments. In `source/AnalysisPayload/utils/AnalysisPayload.cxx`, we'll change from

~~~
int main()
~~~
{: .language-c++}

to

~~~
int main(int argc, char** argv)
~~~
{: .language-c++}

To be specific, `argc` is the number of command line arguments supplied (including the script name itself `AnalysisPayload`) and `argv` are the individual command line arguments passed in with `argv[0] == 'AnalysisPayload'`. We can then override the hard-coded data path if we supply a file by checking if there are at least 2 arguments passed in:

~~~
if(argc >= 2) inputFilePath = argv[1];
~~~
{: .language-c++}

Put that in the right place. Finally, we might also want to specify how many events to run over as well, instead of running over the full file, if we specify it. So then, we can add lines closer to the top of the code:

~~~
Long64_t numEntries(-1);
if(argc >= 3) numEntries  = std::atoi(argv[2]);
// ...
// ...
// get the number of events in the file to loop over
if(numEntries == -1) numEntries = event.getEntries();
std::cout << "Processing " << numEntries << " events" << std::endl;
~~~
{: .language-c++}

removing the other declaration for `numEntries` further down in the code. Once we've done this, let's commit the changes and check out the CI again. We expect it to fail. Now we can go ahead and fix it.

### Updating the CI to point to the data file

Now, the data file we've used was via `wget` but it's also located in an ATLAS-public `eos` space: `/eos/user/g/gstark/public/DAOD_EXOT27.17882744._000026.pool.root.1`. Depending on which top-level `eos` space we're located in, we have to use different xrootd servers to access files:

- `/eos/user -> eosuser.cern.ch`
- `/eos/atlas -> eosatlas.cern.ch`
- `/eos/group -> eosgroup.cern.ch`

By now you should get the idea. Therefore, the xrootd path we use is `root://eosuser.cern.ch//eos/user/g/gstark/public/DAOD_EXOT27.17882744._000026.pool.root.1`. Nicely enough, `TFile::Open` takes in, not only local paths (`file://`), but xrootd paths (`root://`) paths as well [also HTTP and others, but we won't cover that]. Since we've modified the code so we can pass in files instead through the command line:

~~~
script:
  - ...
  - AnalysisPayload root://eosuser.cern.ch//eos/user/g/gstark/public/DAOD_EXOT27.17882744._000026.pool.root.1 1000
~~~
{: .language-yaml}

> ### How many events to run over?
>
> For CI jobs, we want things to run fast and have fast turnaround time. More especially since everyone at CERN shares a pool of runners for most CI jobs, so we should be courteous about the run time of our CI jobs. I generally suggest running over just enough events for you to be able to test what you want to test - whether cutflow or weights.
{: .callout}

Let's go ahead and commit those changes and see if the run job succeeded or not.

~~~
$ AnalysisPayload root://eosuser.cern.ch//eos/user/g/gstark/public/DAOD_EXOT27.17882744._000026.pool.root.1 1000
xAOD::Init                INFO    Environment initialised for data access
TNetXNGFile::Open         ERROR   [ERROR] Server responded with an error: [3010] Unable to give access - user access restricted - unauthorized identity used ; Permission denied

Warning in <xAOD::TReturnCode>:
Warning in <xAOD::TReturnCode>: Unchecked return codes encountered during the job
Warning in <xAOD::TReturnCode>: Number of unchecked successes: 1
Warning in <xAOD::TReturnCode>: To fail on an unchecked code, call xAOD::TReturnCode::enableFailure() at the job's start
Warning in <xAOD::TReturnCode>:
ERROR: Job failed: exit code 1
~~~
{: .output}

Sigh. Another one. Ok, fine, you know what? Let's just deal with this in the next session, ok?

{% include links.md %}
