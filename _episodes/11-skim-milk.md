---
title: "A Skimmer Higgs"
teaching: 5
exercises: 10
objectives:
  - Learn how to skim code and set up artifacts.
questions:
  - How can I run my skimming code in the GitLab CI/CD?
hidden: false
keypoints:
  - Making jobs aware of each other is pretty easy.
  - Artifacts are pretty neat.
  - We're too naive.
---
<iframe width="420" height="263" src="https://www.youtube.com/embed/omYX4uRxCKI?list=PLKZ9c4ONm-VmmTObyNWpz4hB3Hgx8ZWSb" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

# The First Naive Attempt

Let's just attempt to try and get the code working as it is. Since it worked for us already locally, surely the CI/CD must be able to run it??? As a reminder of what we've ended with from the last session:

```yml
stages:
  - greeting
  - build

hello world:
  stage: greeting
  script:
   - echo "Hello World"

.template_build:
  stage: build
  before_script:
   - COMPILER=$(root-config --cxx)
   - FLAGS=$(root-config --cflags --libs)
  script:
   - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS

multi_build:
  extends: .template_build
  image: $ROOT_IMAGE
  parallel:
    matrix:
      - ROOT_IMAGE: ["rootproject/root:6.28.10-ubuntu22.04","rootproject/root:latest"]
```

So we need to do two things:

1. add a `run` stage
2. add a `skim_ggH` job to this stage

Let's go ahead and do that, so we now have three stages

```
stages:
  - greeting
  - build
  - run
```
{: .language-yaml}

and we just need to figure out how to define a run job. Since the skim binary is built, just see if we can run `skim`. Seems too easy to be true?

```
skim_ggH:
  stage: run
  script:
    - ./skim
```
{: .language-yaml}

```
 $ ./skim
 /scripts-178677-36237303/step_script: line 154: ./skim: No such file or directory
```
{: .output}

## We're too naive

Ok, fine. That was way too easy. It seems we have a few issues to deal with.

1. The built code in the `build_skim` job (of the `build` stage) isn't in the `skim_ggH` job by default. We need to use GitLab `artifacts` to copy over this from the right job (and not from `build_skim_latest`).
2. The data (ROOT file) isn't available to the Runner yet.

## Artifacts

`artifacts` is used to specify a list of files and directories which should be attached to the job when it succeeds, fails, or always. The artifacts will be sent to GitLab after the job finishes and will be available for download in the GitLab UI.

> ## More Reading
> - [https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html](https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html)
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

> ## Adding Artifacts
>
> Let's add `artifacts` to our jobs to save the `build/` directory. We'll also make sure the `skim_ggH` job has the right `dependencies` as well. In this case the job multi_build is actually running two parallel jobs: one for the root version 6.28 and the other for the latest version of root. So we have to make sure we specify the right dependency as "multi_build: [rootproject/root:6.28.10-ubuntu22.04]".
>
> > ## Solution
> > ```
> > ...
> > ...
> > .template_build:
> >   stage: build
> >   before_script:
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >   script:
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> >   artifacts:
> >     paths:
> >       - skim
> >     expire_in: 1 day
> > ...
> > ...
> > skim_ggH:
> >   stage: run
> >   dependencies:
> >     - "multi_build: [rootproject/root:6.28.10-ubuntu22.04]"
> >   script:
> >     - ./skim
> > ```
> > {: .language-yaml}
> {: .solution}
{: .challenge}

Ok, it looks like the CI failed because it couldn't find the shared libraries. We should make sure we use the same image to build the skim as we use to run the skim.

> ## Set The Right Image
>
> Update the `skim_ggH` job to use the same image as the `build_skim` job.
>
> > ## Solution
> > ```
> > ...
> > ...
> > skim_ggH:
> >   stage: run
> >   dependencies:
> >     - "multi_build: [rootproject/root:6.28.10-ubuntu22.04]"
> >   image: rootproject/root:6.28.10-ubuntu22.04
> >   script:
> >     - ./skim
> > ```
> > {: .language-yaml}
> {: .solution}
{: .challenge}


# Getting Data

So now we've dealt with the first problem of getting the built code available to the `skim_ggH` job via `artifacts` and `dependencies`. Now we need to think about how to get the data in. We could:

- `wget` the entire ROOT file every time
- `git commit` the ROOT file into the repo
  - ok, maybe not our repo, but another repo that you can add as a submodule so you don't have to clone it every time
- fine, maybe we can make a smaller ROOT file
- what? we don't have time to cover that? ok, can we use `xrdcp`?
- yes, I realize it's a big ROOT file but still...

Anyway, there's lots of options. For large (ROOT) files, it's usually preferable to either

- stream the file event-by-event (or chunks of events at a time) and only process a small number of events
- download a small file that you process entirely

The `xrdcp` option is going to be much easier to deal with in the long run, especially as the data file is on eos.

## Updating the CI to point to the data file

Now, the data file we're going to use via `xrdcp` is in a public `eos` space: `/eos/root-eos/HiggsTauTauReduced/`. Depending on which top-level `eos` space we're located in, we have to use different xrootd servers to access files:

- `/eos/user -> eosuser.cern.ch`
- `/eos/atlas -> eosatlas.cern.ch`
- `/eos/group -> eosgroup.cern.ch`
- `/eos/root-eos -> eospublic.cern.ch`

**Note: the other eos spaces are NOT public**

> ## What files are in here?
>
> By now, you should get the idea of how to explore eos spaces.
> ```
> $ xrdfs eospublic.cern.ch ls /eos/root-eos/HiggsTauTauReduced/
> /eos/root-eos/HiggsTauTauReduced/DYJetsToLL.root
> /eos/root-eos/HiggsTauTauReduced/GluGluToHToTauTau.root
> /eos/root-eos/HiggsTauTauReduced/Run2012B_TauPlusX.root
> /eos/root-eos/HiggsTauTauReduced/Run2012C_TauPlusX.root
> /eos/root-eos/HiggsTauTauReduced/TTbar.root
> /eos/root-eos/HiggsTauTauReduced/VBF_HToTauTau.root
> /eos/root-eos/HiggsTauTauReduced/W1JetsToLNu.root
> /eos/root-eos/HiggsTauTauReduced/W2JetsToLNu.root
> /eos/root-eos/HiggsTauTauReduced/W3JetsToLNu.root
> ```
> {: .language-bash}
{: .callout}

- **For those of you with CERN accounts**, I've provided a file we should use in a CERN-restricted space here: `/eos/user/g/gstark/AwesomeWorkshopFeb2020/GluGluToHToTauTau.root`. Therefore, the xrootd path we use is `root://eosuser.cern.ch//eos/user/g/gstark/AwesomeWorkshopFeb2020/GluGluToHToTauTau.root`
- **For those of you without CERN accounts**, we have provided a file we should use in a public space here: `/eos/root-eos/HiggsTauTauReduced/GluGluToHToTauTau.root`. Therefore, the xrootd path we use is `root://eospublic.cern.ch//eos/root-eos/HiggsTauTauReduced/GluGluToHToTauTau.root`.

Nicely enough, `TFile::Open` takes in, not only local paths (`file://`), but xrootd paths (`root://`) paths as well (also HTTP and others, but we won't cover that). Since we've modified the code we can now pass in files:

```
script:
  - ./skim root://eosuser.cern.ch//eos/user/g/gstark/AwesomeWorkshopFeb2020/GluGluToHToTauTau.root skim_ggH.root 19.6 11467.0 0.1

# or (if you don't have CERN accounts)

script:
  - ./skim root://eospublic.cern.ch//eos/root-eos/HiggsTauTauReduced/GluGluToHToTauTau.root skim_ggH.root 19.6 11467.0 0.1
```
{: .language-yaml}

> ## How many events to run over?
>
> For CI jobs, we want things to run fast and have fast turnaround time. More especially since everyone at CERN shares a pool of runners for most CI jobs, so we should be courteous about the run time of our CI jobs. I generally suggest running over just enough events for you to be able to test what you want to test - whether cutflow or weights.
{: .callout}

Let's go ahead and commit those changes and see if the run job succeeded or not.

- If you use the file in a public space, your job will succeed.
- If you use the file in a CERN-restricted space, your job will fail with a similar error below:

```
$ ./skim root://eosuser.cern.ch//eos/user/g/gstark/AwesomeWorkshopFeb2020/GluGluToHToTauTau.root skim_ggH.root 19.6 11467.0 0.1
>>> Process input: root://eosuser.cern.ch//eos/user/g/gstark/AwesomeWorkshopFeb2020/GluGluToHToTauTau.root
Error in <TNetXNGFile::Open>: [ERROR] Server responded with an error: [3010] Unable to give access - user access restricted - unauthorized identity used ; Permission denied
Warning in <TTreeReader::SetEntryBase()>: There was an issue opening the last file associated to the TChain being processed.
Number of events: 0
Cross-section: 19.6
Integrated luminosity: 11467
Global scaling: 0.1
Error in <TNetXNGFile::Open>: [ERROR] Server responded with an error: [3010] Unable to give access - user access restricted - unauthorized identity used ; Permission denied
terminate called after throwing an instance of 'std::runtime_error'
  what():  GetBranchNames: error in opening the tree Events
/bin/bash: line 87:    13 Aborted                 (core dumped) ./skim root://eosuser.cern.ch//eos/user/g/gstark/AwesomeWorkshopFeb2020/GluGluToHToTauTau.root skim_ggH.root 19.6 11467.0 0.1
section_end:1581450227:build_script
ERROR: Job failed: exit code 1
```
{: .output}

Sigh. Another one. Ok, fine, you know what? Let's just deal with this in the next session, ok?

{% include links.md %}
