---
title: Homework
teaching: 0
exercises: 30
objectives:
  - Add more testing, perhaps to statistics.
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

In your `virtual-pipelines-eventselection` repository, you need to:

1. Add more tests for physics
2. Go wild!

{% include links.md %}
