---
title: "Hello CI World"
teaching: 5
exercises: 10
objectives:
  - Add CI/CD to your project.
questions:
  - How do I run a simple GitLab CI job?
hidden: false
keypoints:
  - Adding a `.gitlab-ci.yml` is the first step to salvation.
  - Pipelines are made of stages, stages are made of jobs.
  - CI Linters are especially useful to check syntax before pushing changes.
---
<iframe width="420" height="263" src="https://www.youtube.com/embed/LqeJzIYJCwc?list=PLKZ9c4ONm-VmmTObyNWpz4hB3Hgx8ZWSb" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
# Adding CI/CD to a project

We've been working on the analysis code which has a lot of work done, but we should be good physicists (and people) by adding tests and CI/CD. The first thing we'll do is create a `.gitlab-ci.yml` file in the project.

~~~
cd virtual-pipelines-eventselection/
echo "hello world" >> .gitlab-ci.yml
git checkout -b feature/add-ci
git add .gitlab-ci.yml
git commit -m "my first ci/cd"
git push -u origin feature/add-ci
~~~
{: .source}

> ## Feature Branches
>
> Since we're adding a new feature (CI/CD) to our project, we'll work in a feature branch. This is just a human-friendly named branch to indicate that it's adding a new feature.
{: .callout}

Now, if you navigate to the GitLab webpage for that project and branch, you'll notice a shiny new button

![CI/CD Configuration Button]({{site.baseurl}}/fig/ci-cd-configuration-button.png)

which will link to the newly added `.gitlab-ci.yml`. But wait a minute, there's also a big red `x` on the page too!

![Commit's CI/CD Failure Example]({{site.baseurl}}/fig/ci-cd-commit-failure.png)

What happened??? Let's find out. Click on the red `x` which takes us to the `pipelines` page for the commit. On this page, we can see that this failed because the YAML was invalid...

![CI/CD Failure YAML Invalid]({{site.baseurl}}/fig/ci-cd-commit-failure-yaml-invalid.png)

We should fix this. If you click through again on the red `x` on the left for the pipeline there, you can get to the detailed page for the given pipeline to find out more information

![CI/CD Failure YAML Invalid Pipeline page]({{site.baseurl}}/fig/ci-cd-commit-failure-yaml-invalid-pipeline-page.png)

> ## Validating CI/CD YAML Configuration
>
> Every single project you make on GitLab comes with a linter for the YAML you write. This linter can be found at `<project-url>/-/ci/lint`. For example, if I have a project at [https://gitlab.cern.ch/MultiBJets/MBJ_Analysis](https://gitlab.cern.ch/MultiBJets/MBJ_Analysis), then the linter is at [https://gitlab.cern.ch/MultiBJets/MBJ_Analysis/-/ci/lint](https://gitlab.cern.ch/MultiBJets/MBJ_Analysis/-/ci/lint).
>
> This can also be found by going to `CI/CD -> Pipelines` or `CI/CD -> Jobs` page and clicking the `CI Lint` button at the top right.
{: .callout}

> ### But what's a linter?
>
> From [wikipedia](https://en.wikipedia.org/wiki/Lint_(software)): `lint`, or a linter, is a tool that analyzes source code to flag programming errors, bugs, stylistic errors, and suspicious constructs. The term originates from a Unix utility that examined C language source code.
{: .callout}

Lastly, we'll open up a merge request for this branch, since we plan to merge this back into master when we're happy with the first iteration of the CI/CD.

> ## Work In Progress?
>
> If you expect to be working on a branch for a bit of time while you have a merge request open, it's good etiquette to mark it as a Work-In-Progress (WIP).
> ![Work In Progress]({{site.baseurl}}/fig/work-in-progress.png)
{: .callout}

# Hello World

## Fixing the YAML

Now, our YAML is currently invalid, but this makes sense because we didn't actually define any script to run. Let's go ahead and update our first job that simply echoes "Hello World".

~~~
hello world:
  script: echo "Hello World"
~~~
{: .language-yaml}

Before we commit it, since we're still new to CI/CD, let's copy/paste it into the CI linter and make sure it lints correctly

![CI/CD Hello World Lint]({{site.baseurl}}/fig/ci-cd-hello-world-lint.png)

Looks good! Let's stage the changes with `git add .gitlab-ci.yml`, commit it with an appropriate commit message, and push!

## Checking Pipeline Status

Now we want to make sure that this worked. How can we check the status of commits or pipelines? The GitLab UI has a couple of ways:

- go to the `commits` page of your project and see the pipeline's status for that commit
  ![CI/CD Commits Page]({{site.baseurl}}/fig/ci-cd-commits-page.png)
- go to `CI/CD -> Pipelines` of your project, see all pipelines, and find the right one
  ![CI/CD Pipelines Page]({{site.baseurl}}/fig/ci-cd-pipelines-page.png)
- go to `CI/CD -> Jobs` of your project, see all jobs, and find the right one
  ![CI/CD Jobs Page]({{site.baseurl}}/fig/ci-cd-jobs-page.png)

## Checking Job's Output

From any of these pages, click through until you can find the output for the successful job run which should look like the following

![CI/CD Hello World Success Output]({{site.baseurl}}/fig/ci-cd-hello-world-success-output.png)

And that's it! You've successfully run your CI/CD job and you can view the output.

# Pipelines and Jobs?

You might have noticed that there are both `pipelines` and `jobs`. What's the difference? **Pipelines** are the top-level component of continuous integration, delivery, and deployment.

Pipelines comprise:

- Jobs that define what to run. For example, code compilation or test runs.
- Stages that define when and how to run. For example, that tests run only after code compilation.

Multiple jobs in the same stage are executed by Runners in parallel, if there are enough concurrent Runners.

If all the jobs in a stage:

- Succeed, the pipeline moves on to the next stage.
- Fail, the next stage is not (usually) executed and the pipeline ends early.


{% include links.md %}
