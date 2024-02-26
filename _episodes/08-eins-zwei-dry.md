---
title: "Eins Zwei DRY"
teaching: 5
exercises: 10
objectives:
  - Don't Repeat Yourself (DRY)
  - Making reusable/flexible CI/CD jobs
questions:
  - How can we make job templates?
hidden: false
keypoints:
  - Hidden jobs can be used as templates with the `extends` parameter.
  - Using job templates allows you to stay DRY!
---
<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/Ai9Vc1e5tB0?si=8j64O61cC1UXdlIC" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
<iframe width="420" height="236" src="https://www.youtube.com/embed/dSy2DcATYUo" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
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

Why is this fun? We should be able to combine it with some other nice features of GitLab's CI YAML to build...

# Job Templates

From the previous lesson, our `.gitlab-ci.yml` looks like

~~~
hello_world:
  script:
    - echo "Hello World"

build_skim:
  before_script:
    - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
    - bash ~/miniconda.sh -b -p $HOME/miniconda
    - eval "$(~/miniconda/bin/conda shell.bash hook)"
    - conda init
  script:
    - conda install root=6.28
    - COMPILER=$(root-config --cxx)
    - FLAGS=$(root-config --cflags --libs)
    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS

build_skim_latest:
  before_script:
    - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
    - bash ~/miniconda.sh -b -p $HOME/miniconda
    - eval "$(~/miniconda/bin/conda shell.bash hook)"
    - conda init
  script:
    - conda install root
    - COMPILER=$(root-config --cxx)
    - FLAGS=$(root-config --cflags --libs)
    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
  allow_failure: true
~~~
{: .language-yaml}

We've already started to repeat ourselves. How can we combine the two into a single job template called `.template_build`? Let's refactor things a little bit.

> ## Refactoring the code
>
> Can you refactor the above code by adding a hidden job (named `.template_build`) containing parameters that `build_skim` and `build_skim_version` have in common?
>
> > ## Solution
> > ~~~
> > hello_world:
> >   script:
> >     - echo "Hello World"
> >
> > .template_build:
> >   before_script:
> >     - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
> >     - bash ~/miniconda.sh -b -p $HOME/miniconda
> >     - eval "$(~/miniconda/bin/conda shell.bash hook)"
> >     - conda init
> >
> >
> > build_skim:
> >   before_script:
> >     - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
> >     - bash ~/miniconda.sh -b -p $HOME/miniconda
> >     - eval "$(~/miniconda/bin/conda shell.bash hook)"
> >     - conda init
> >   script:
> >    - conda install root=6.28 --yes
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> >
> >
> > build_skim_latest:
> >   before_script:
> >     - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
> >     - bash ~/miniconda.sh -b -p $HOME/miniconda
> >     - eval "$(~/miniconda/bin/conda shell.bash hook)"
> >     - conda init
> >   script:
> >    - conda install root --yes
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> >   allow_failure: true
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

The idea behind not repeating yourself is to merge multiple (job) definitions together, usually a hidden job and a non-hidden job. This is done through a concept of inheritance. Interestingly enough, GitLab CI/CD also allows for `:job:extends` as an alternative to using YAML anchors. I tend to prefer this syntax as it appears to be "more readable and slightly more flexible" (according to GitLab - but I argue it's simply just more readable and has identical functionality!!!).

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
> If we use `extends` to remove duplicate code, what do we get?
>
> > ## Solution
> > ~~~
> > hello_world:
> >   script:
> >     - echo "Hello World"
> >
> > .template_build:
> >   before_script:
> >     - wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniconda.sh
> >     - bash ~/miniconda.sh -b -p $HOME/miniconda
> >     - eval "$(~/miniconda/bin/conda shell.bash hook)"
> >     - conda init
> >
> >
> > build_skim:
> >   extends: .template_build
> >   script:
> >    - conda install root=6.28 --yes
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> >
> >
> > build_skim_latest:
> >   extends: .template_build
> >   script:
> >    - conda install root --yes
> >    - COMPILER=$(root-config --cxx)
> >    - FLAGS=$(root-config --cflags --libs)
> >    - $COMPILER -g -O3 -Wall -Wextra -Wpedantic -o skim skim.cxx $FLAGS
> >   allow_failure: yes
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

Look how much cleaner you've made the code. You should now see that it's pretty easy to start adding more build jobs for other versions in a relatively clean way, as you've now abstracted the actual building from the definitions.

{% include links.md %}
