---
title: Homework
teaching: 0
exercises: 20
objectives:
  - Add testing to the awesome-analysis-statistics repository.
questions:
  - If you have any, ask on mattermost!
hidden: false
keypoints:
  - Use everything you've learned to write your own CI/CD!
---

Like the last section, I will simply explain what you need to do. After the previous section, you should have the following in `.gitlab-ci.yml`:

~~~
stages:
  - build
  - run
  - plot
  - test

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
    - ./skim root://eosuser.cern.ch//eos/user/g/gstark/AwesomeWorkshopFeb2020/GluGluToHToTauTau.root skim_ggH.root 19.6 11467.0 0.1 > skim_ggH.log
  artifacts:
    paths:
      - skim_ggH.root
      - skim_ggH.log
    expire_in: 1 week

plot_ggH:
  stage: plot
  dependencies:
    - skim_ggH
  image: rootproject/root-conda:6.18.04
  script:
    - python histograms.py skim_ggH.root ggH hist_ggH.root
  artifacts:
    paths:
      - hist_ggH.root
    expire_in: 1 week

test_ggH:
  stage: test
  dependencies:
    - skim_ggH
    - plot_ggH
  image: rootproject/root-conda:6.18.04
  script:
    - python tests/test_cutflow_ggH.py
    - python tests/test_plot_ggH.py
~~~
{: .language-yaml}

In your `awesome-analysis-statistics` repository, you need to:

1. Add a `.gitlab-ci.yml` file
2. Add a single stage called `fit` with a single job called `fit_simple`.
3. Use the same docker images we've used for the `awesome-analysis-eventselection` CI/CD
4. Create a script that does the following:
  - makes an output directory for the fit outputs, likely called `fit_outputs`
  - runs `python fit.py histograms.root fit_outputs`
5. Make sure that the `fit_outputs` is stored as an artifact as part of the pipeline that expires in a week.

In order to get the histograms into your CI/CD, you will need to `xrdcp` the `histograms.root` file from your EOS user-space. Remember that anything under `/eos/user` is accessible via `eosuser.cern.ch`. This can be copied over in your CI/CD via something like `xrdcp root://eosuser.cern.ch//eos/user/a/abc/awesome-analysis/histograms/histograms.root histograms.root` as long as you have your kerberos session set-up.

{% include links.md %}
