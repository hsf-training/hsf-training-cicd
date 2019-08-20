---
title: "Eins Zwei DRY"
teaching: 5
exercises: 15
objectives:
  - Don't Repeat Yourself (DRY)
  - Making reusable/flexible CI/CD jobs
questions:
  - How can we make job templates?
hidden: false
keypoints:
  - Hidden jobs can be used as templates with anchors or the `extends` parameter.
  - Using job templates allows you to stay DRY!
---

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/dSy2DcATYUo" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>

# Hidden (keys) Jobs

A fun [feature](https://docs.gitlab.com/ee/ci/yaml/README.html#special-yaml-features) about GitLab's CI YAML is the ability to disable entire jobs simply by prefixing the job name with a period (`.`). Naively, we could just comment it out

~~~
#hidden job:
#  script:
#    - make
~~~
{: .language-yaml}

but it's much easier to simply write

~~~
.hidden job:
  script:
    - make
~~~
{: .language-yaml}

Why is this fun? We should be able to combine it with some other nice features of YAML to build...

# Job Templates

Remember back in the [YAML lesson, we covered anchors]({{site.baseurl}}/04-understanding-yaml/#anchors)? We can combine this with GitLab's syntax for hidden keys to create these job templates. From the previous lesson, our `.gitlab-ci.yml` looks like

~~~
variables:
  GIT_SUBMODULE_STRATEGY: recursive

hello world:
  script:
    - echo "Hello World"
    - find . -path ./.git -prune -o -print

build:
  image: atlas/analysisbase:21.2.85-centos7
  before_script:
    - source /home/atlas/release_setup.sh
  script:
    - mkdir build
    - cd build
    - cmake ../source
    - cmake --build .

build_latest:
  image: atlas/analysisbase:latest
  before_script:
    - source /home/atlas/release_setup.sh
  script:
    - mkdir build
    - cd build
    - cmake ../source
    - cmake --build .
  allow_failure: yes
~~~
{: .language-yaml}

We've already started to repeat ourselves. How can we combine the two into a single job template called `.build_template`? Let's refactor things a little bit, but it's up to **you** to fill in the last few steps with [anchors]({{site.baseurl}}/04-understanding-yaml/#anchors).

> ## Refactoring the code
>
> Can you refactor the above code by adding a hidden job containing parameters that `build` and `build_latest` have in common?
>
> > ## Solution
> > ~~~
> > variables:
> >   GIT_SUBMODULE_STRATEGY: recursive
> >
> > hello world:
> >   script:
> >     - echo "Hello World"
> >     - find . -path ./.git -prune -o -print
> >
> > .build_template:
> >   before_script:
> >     - source /home/atlas/release_setup.sh
> >   script:
> >     - mkdir build
> >     - cd build
> >     - cmake ../source
> >     - cmake --build .
> >
> > build:
> >   image: atlas/analysisbase:21.2.85-centos7
> >   before_script:
> >     - source /home/atlas/release_setup.sh
> >   script:
> >     - mkdir build
> >     - cd build
> >     - cmake ../source
> >     - cmake --build .
> >
> > build_latest:
> >   image: atlas/analysisbase:latest
> >   before_script:
> >     - source /home/atlas/release_setup.sh
> >   script:
> >     - mkdir build
> >     - cd build
> >     - cmake ../source
> >     - cmake --build .
> >   allow_failure: yes
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

The idea behind everything for anchors is to merge multiple (job) definitions together, usually a hidden job and a non-hidden job.

> ## Anchors Aweigh
>
> Using the anchor `&build_definition`, can you use anchors and merge in the definition to `build` and `build_latest`?
>
> > ## Solution
> > ~~~
> > variables:
> >   GIT_SUBMODULE_STRATEGY: recursive
> >
> > hello world:
> >   script:
> >     - echo "Hello World"
> >     - find . -path ./.git -prune -o -print
> >
> > .build_template: &build_definition
> >   before_script:
> >     - source /home/atlas/release_setup.sh
> >   script:
> >     - mkdir build
> >     - cd build
> >     - cmake ../source
> >     - cmake --build .
> >
> > build:
> >   <<: *build_definition
> >   image: atlas/analysisbase:21.2.85-centos7
> >
> > build_latest:
> >   <<: *build_definition
> >   image: atlas/analysisbase:latest
> >   allow_failure: yes
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

Interestingly enough, GitLab CI/CD also allows for `:job:extends` as an alternative to using anchors. I tend to prefer this syntax as it appears to be "more readable and slightly more flexible" (according to GitLab - but I argue it's simply just more readable and has identical functionality!!!).

~~~
.only-important:
  only:
    - master
    - stable
  tags:
    - production

.in-docker:
  tags:
    - docker
  image: alpine

rspec:
  extends:
    - .only-important
    - .in-docker
  script:
    - rake rspec
~~~
{: .language-yaml}

will become

~~~
rspec:
  only:
    - master
    - stable
  tags:
    - docker
  image: alpine
  script:
    - rake rspec
~~~
{: .language-yaml}

Note how `.in-docker` overrides `:rspec:tags` because it's "closest in scope".

> ## Anchors Away?
>
> If we do away with anchors (removing `&build_definition`) and use `extends` instead, what does the code look like?
>
> > ## Solution
> > ~~~
> > variables:
> >   GIT_SUBMODULE_STRATEGY: recursive
> >
> > hello world:
> >   script:
> >     - echo "Hello World"
> >     - find . -path ./.git -prune -o -print
> >
> > .build_template:
> >   before_script:
> >     - source /home/atlas/release_setup.sh
> >   script:
> >     - mkdir build
> >     - cd build
> >     - cmake ../source
> >     - cmake --build .
> >
> > build:
> >   extends: .build_template
> >   image: atlas/analysisbase:21.2.85-centos7
> >
> > build_latest:
> >   extends: .build_template
> >   image: atlas/analysisbase:latest
> >   allow_failure: yes
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

Look how much cleaner you've made the code. You should now see that it's pretty easy to start adding more build jobs for other images in a relatively clean way, as you've now abstracted the actual building from the definitions.

{% include links.md %}
