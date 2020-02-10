---
title: "All the World's a Stage"
teaching: 5
exercises: 5
objectives:
  - Make multiple stages and run some jobs in serial.
questions:
  - How do you make some jobs run after other jobs?
hidden: false
keypoints:
  - Stages allow for a mix of parallel/serial execution.
  - Stages help define job dependencies.
---

# Defining Stages

From the last session, we're starting with

~~~
hello world:
  script:
   - echo "Hello World"

.build_template:
  before_script:
   - COMPILER=$(root-config --cxx)
   - FLAGS=$(root-config --cflags --libs)
  script:
   - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS

build_skim:
  extends: .build_template
  image: rootproject/root-conda:6.18.04

build_skim_latest:
  extends: .build_template
  image: rootproject/root-conda:latest
  allow_failure: yes
~~~
{: .language-yaml}

We're going to talk about another global parameter `:stages` (and the associated per-job parameter `:job:stage`. Stages allow us to group up parallel jobs with each group running after the other in the order you define. What have our jobs looked like so far in the pipelines we've been running?

![CI/CD Default Stages in Pipeline]({{site.baseurl}}/fig/ci-cd-default-stages.png)

> ## Default Stage
>
> You'll note that the default stage is `test`. Of course, for CI/CD, this is likely the most obvious choice.
{: .callout}

Stages allow us to categorize jobs by functionality, such as `build`, or `test`, or `deploy` -- with job names being the next level of specification such as `test_cpp`, `build_current`, `build_latest`, or `deploy_pages`. Remember that two jobs cannot have the same name (globally), no matter what stage they're in. Like the other global parameter `variables`, we keep `stages` towards the top of our `.gitlab-ci.yml` file.

> ## Adding Stages
>
> Let's add stages to your code. We will define five stages in preparation for the rest of the stuff we want to add: `greeting`, `build`, `run`, `cutflow`, and `plot`. Don't forget to assign those stages to the appropriate jobs (the last three we leave unassigned).
>
> > ## Solution
> > ~~~
> > stages:
> >   - greeting
> >   - build
> >   - run
> >   - cutflow
> >   - plot
> >
> > hello world:
> >   stage: greeting
> >   script:
> >    - echo "Hello World"
> >
> > .build_template:
> >   stage: build
> >   before_script:
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >   script:
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> >
> > build_skim:
> >   extends: .build_template
> >   image: rootproject/root-conda:6.18.04
> >
> > build_skim_latest:
> >   extends: .build_template
> >   image: rootproject/root-conda:latest
> >   allow_failure: yes
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

If you do it correctly, you should see a pipeline graph with two stages

![CI/CD Pipeline Two Stages]({{site.baseurl}}/fig/ci-cd-pipeline-two-stages.png)

Now all jobs in `greeting` run first, before all jobs in `build` (as this is the order we've defined our stages). All jobs within a given stage run in parallel as well.

That's it. There's nothing more to `stages` apart from that! In fact, everything in terms of parallel/serial as well as job dependencies only make sense in the context of having multiple stages. In all the previous sessions, you've just been using the default `test` stage for all jobs; the jobs all ran in parallel.

> ## Further Reading
> - [https://docs.gitlab.com/ee/ci/yaml/#stages](https://docs.gitlab.com/ee/ci/yaml/#stages)
{: .checklist}

{% include links.md %}
