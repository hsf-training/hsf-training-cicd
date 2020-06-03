---
title: "Making Plots to Take Over The World"
teaching: 5
exercises: 10
objectives:
  - Use everything you learned to make plots!
questions:
  - How do we make plots?
hidden: false
keypoints:
  - Another script, another job, another stage, another artifact.
---

# On Your Own

So in order to make plots, we just need to take the skimmed file `skim_ggH.root` and pass it through the `histograms.py` code that exists. This can be run with the following code

~~~
python histograms.py skim_ggH.root ggH hist_ggH.root
~~~
{: .language-bash}

This needs to be added to your `.gitlab-ci.yml` which should look like the following:

~~~
stages:
  - greeting
  - build
  - run
  - plot

hello world:
  stage: greeting
  script:
   - echo "Hello World"

.build_template:
  stage: build
  before_script:
   - COMPILER=$(root-config --cxx)
   - FLAGS=$(root-config --cflags --libs)
  script:
   - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
  artifacts:
    paths:
      - skim
    expire_in: 1 day

build_skim:
  extends: .build_template
  image: rootproject/root-conda:6.18.04

build_skim_latest:
  extends: .build_template
  image: rootproject/root-conda:latest
  allow_failure: yes

skim_ggH:
  stage: run
  dependencies:
    - build_skim
  image: rootproject/root-conda:6.18.04
  before_script:
    - printf $SERVICE_PASS | base64 -d | kinit $CERN_USER@CERN.CH
  script:
    - ./skim root://eosuser.cern.ch//eos/user/g/gstark/AwesomeWorkshopFeb2020/GluGluToHToTauTau.root skim_ggH.root 19.6 11467.0 0.1
  artifacts:
    paths:
      - skim_ggH.root
    expire_in: 1 week
~~~
{: .language-yaml}

> ## Adding Artifacts
>
> So we need to do a few things:
>
> 1. add a `plot` stage
> 2. add a `plot_ggH` job
> 3. save the output `hist_ggH.root` as an artifact (expires in 1 week)
>
> You know what? While you're at it, why not delete the `greeting` stage and `hello_world` job too? There's no need for it anymore 🙂.
>
> > ## Solution
> > ~~~
> > stages:
> >   - build
> >   - run
> >   - plot
> > ...
> > ...
> > ...
> > plot_ggH:
> >   stage: plot
> >   dependencies:
> >     - skim_ggH
> >   image: rootproject/root-conda:6.18.04
> >   script:
> >     - python histograms.py skim_ggH.root ggH hist_ggH.root
> >   artifacts:
> >     paths:
> >       - hist_ggH.root
> >     expire_in: 1 week
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

Once we're done, we should probably start thinking about how to test some of these outputs we've made. We now have a skimmed ggH ROOT file and a file of histograms of the skimmed ggH.

> ## Are we testing anything?
>
> Integration testing is actually testing that the scripts we have still run. So we are constantly testing as we go here which is nice. Additionally, there's also continuous deployment because we've been making artifacts that are passed to other jobs. There are many ways to deploy the results of the code base, such as pushing to a web server, or putting files on EOS from the CI jobs, and so on. Artifacts are one way to deploy.
{: .callout}


{% include links.md %}
