---
title: "Running our Containerized Analysis"
teaching: 10
exercises: 35
questions:
- "How do I run my full analysis chain inside docker containers?"
objectives:
- "Try running your entire analysis workflow in containerized environments."
- "Gain an appreciation for the convenience of automating containerized workflows."
keypoints:
- "Containerized analysis environments allow for fully reproducible code testing and development, with the convenience of working on your local machine."
- "Fortunately, there are tools to help you automate all of this."
---
<iframe width="427" height="251" src="https://www.youtube.com/embed/SMyI7vz0EAY?list=PLKZ9c4ONm-VnqD5oN2_8tXO0Yb1H_s0sj" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Introduction

To bring it all together, we can also preserve our fitting framework in its own docker image, then run our full analysis workflow within these containerized environments.

## Preserve the Fitting Repo Environment

> ## Exercise (10 min)
> Just as we did for the analysis repo, cd into your the repo containing your statistical fitting code and create a Dockerfile to preserve the environment. You can again start from the `rootproject/root:6.22.06-conda` base image.
>
> **Note:** Since the fitting code just runs a python script, there's no need to pre-compile any executables in this Dockerfile. It's sufficient to add the source code to the base image and make the directory containing the code your default working directory.'
>
> Once you're happy with the Dockerfile, commit and push the new file to the fitting repo.
>
> **Note:** Since we're now moving between repos, you can quickly double-check that you're in the desired repo using eg. `git remote -v`.
> > ## Solution
> > ~~~yaml
> > FROM rootproject/root:6.22.06-conda
> > COPY . /fit
> > WORKDIR /fit
> > ~~~
> > {: .source}
> {: .solution}
{: .challenge}

> ## Exercise (5 min)
> Now, add the same image-building stage to the `.gitlab-ci.yml` file as we added for the skimming repo. You will also need to add a `- build` stage at the top in addition to any other stages.
>
> **Note:** I would suggest listing the `- build` stage before the other stages so it will run first. This way, even if the other stages fail for whatever reason, the image can still be built with the `- build` stage.
>
> Once you're happy with the .gitlab-ci.yml, commit and push the new file to the fitting repo.
> > ## Solution
> > ~~~yaml
> > stages:
> > - build
> > - [... any other stages]
> >
> > build_image:
> >   stage: build
> >   variables:
> >     TO: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG-$CI_COMMIT_SHORT_SHA
> >   tags:
> >     - docker-image-build
> >   script:
> >     - ignore
> >
> > [... rest of .gitlab-ci.yml]
> > ~~~
> > {: .source}
> {: .solution}
{: .challenge}

If the image-building completes successfully, you should be able to pull your fitting container, just as you did the skimming container:

~~~bash
docker login gitlab-registry.cern.ch
docker pull gitlab-registry.cern.ch/[repo owner's username]/[fitting repo name]:[branch name]-[shortened commit sha]
~~~
{: .source}

## Running the Containerized Workflow

Now that we've preserved our full analysis environment in docker images, let's try running the workflow in these containers all the way from input samples to final fit result. To add to the fun, you can try doing the analysis in a friend's containers!

> ## Friend Time Activity (20 min)
>
> ### Part 1: Skimming
> Make a directory, eg. `containerized_workflow`, from which to do the analysis. `cd` into the directory and make sub-directories to contain the skimming and fitting output:
>
> ~~~bash
> mkdir containerized_workflow
> cd containerized_workflow
> mkdir skimming_output
> mkdir fitting_output
> ~~~
>
> Find a partner and pull the image they've built for their skimming repo from the gitlab registry. Launch a container using your partner's image. Try to run the analysis code to produce the `histogram.root` file that will get input to the fitting repo, using the `skim_prebuilt.sh` script we created in the previous lesson for the first skimming step. You can follow the skimming instructions in [step 1](https://gitlab.cern.ch/awesome-workshop/awesome-analysis-eventselection-stage2/blob/master/README.md#step-1-skimming) and [step 2](https://gitlab.cern.ch/awesome-workshop/awesome-analysis-eventselection-stage2/blob/master/README.md#step-2-histograms) of the README.
>
> **Note:** We'll need to pass the output from the skimming stage to the fitting stage. To enable this, you can volume mount the `skimming_output` directory into the container. Then, as long as you save the skimming output to the volume-mounted location in the container, it will also be available locally under `skimming_output`.
>
> ### Part 2: Fitting
> Now, pull your partner's fitting image and use it to produce the final fit result. Remember to volume-mount the `skimming_output` and `fitting_output` so the container has access to both. At the end, the `fitting_output` directory on your local machine should contain the final fit results. You can follow the instructions in [step 4](https://gitlab.cern.ch/awesome-workshop/awesome-analysis-eventselection-stage2/blob/master/README.md#step-4-fit) of the README.
>
> > ## Solution
> > ### Part 1:  Skimming
> > ~~~bash
> > # Pull the image for the skimming repo
> > docker pull gitlab-registry.cern.ch/[your_partners_username]/[skimming repo name]:[branch name]-[shortened commit SHA]
> >
> > # Start up the container and volume-mount the skimming_output directory into it
> > docker run --rm -it -v ${PWD}/skimming_output:/skimming_output gitlab-registry.cern.ch/[your_partners_username]/[skimming repo name]:[branch name]-[shortened commit SHA] /bin/bash
> >
> > # Run the skimming code
> > bash skim_prebuilt.sh root://eospublic.cern.ch//eos/root-eos/HiggsTauTauReduced/ /skimming_output
> > bash histograms.sh /skimming_output /skimming_output
> > ~~~
> > {: .source}
> >
> > ### Part 2: Fitting
> > ~~~bash
> > # Pull the image for the fitting repo
> > docker pull gitlab-registry.cern.ch/[your_partners_username]/[fitting repo name]:[branch name]-[shortened commit SHA]
> >
> > # Start up the container and volume-mount the skimming_output and fitting_output directories into it
> > docker run --rm -it -v ${PWD}/skimming_output:/skimming_output -v ${PWD}/fitting_output:/fitting_output gitlab-registry.cern.ch/[your_partners_username]/[fitting repo name]:[branch name]-[shortened commit SHA] /bin/bash
> >
> > # Run the fitting code
> > bash fit.sh /skimming_output/histograms.root /fitting_output
> > ~~~
> {: .solution}
{: .testimonial}

> ## Containerized Workflow Automation
> At this point, you may already have come to appreciate that it could get a bit tedious having to manually start up the containers and keep track of the mounted volumes every time you want to develop and test your containerized workflow. It would be pretty nice to have something to automate all of this.
>
> <img src="../fig/BeachBoys.png" alt="BeachBoys" style="width:300px">
>
> Fortunately, containerized workflow automation tools such as [yadage](https://yadage.github.io/tutorial/) have been developed to do exactly this. Yadage was developed by Lukas Heinrich specifically for HEP applications, and is now used widely in ATLAS for designing re-interpretable analyses.
{: .callout}

{% include links.md %}
