---
title: "Building with Images"
teaching: 10
exercises: 5
objectives:
  - Use docker images
  - Making reusable/flexible CI/CD jobs
questions:
  - Can we use docker images to ease our setup?
hidden: false
keypoints:
  - We can shorten a lot of the setup with Docker images
---
<iframe width="560" height="315" src="https://www.youtube.com/embed/mWUyoFwjxto?si=TGVrpH2BZzsS-f80" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

# Say "Docker" 🐳

While we won't be going into detail about containers (for that check [our Docker lesson](https://hsf-training.github.io/hsf-training-docker/)), we've been using them all this time with Gitlab. Gitlab runners are working within a barebones virtual environment that runs Linux, and is itself an image.

Naturally, we can leverage the fact that Gitlab runners can run Docker to further simplify setting up the working environment. This is done using the `image` keyword. The input for `image` is the name of the image, including the registry path if needed, in one of these formats:

- `<image-name>` (Same as using `<image-name>` with the latest tag)
- `<image-name>:<tag>`
- `<image-name>@<digest>`


 Here's an example:

```yml
tests:
  image: $IMAGE
  script:
    - python3 --version
  parallel:
    matrix:
      - IMAGE: "python:3.7-buster"
      - IMAGE: "python:3.8-buster"
      - IMAGE: "python:3.9-buster"
      - IMAGE: "python:3.10-buster"
      - IMAGE: "python:3.11-buster"
#   You could also do
# - IMAGE: ["python:3.7-buster","python:3.8-buster","python:3.9-buster","python:3.10-buster","python:3.11-buster"]
```


# Back to our CI file

Go to the ROOT docker hub page <https://hub.docker.com/r/rootproject/root> and choose a version any version you wish to try.

Let's add `image: $ROOT_IMAGE` because we can still use `parallel:matrix:` to make various builds easily.
Since we're going to use a docker image to have a working version of ROOT, we can omit the lines that install and set up conda and ROOT.
Again, taking the yml file we've been working on, we can further reduce the text using Docker images as follows.

```yml
hello_world:
  script:
    - echo "Hello World"

.template_build:
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


> ## Note
>  We used the `latest` docker image and an `ubuntu` image in this particular example but the script remains the same
>  regardless if you wish to use the conda build or an ubuntu build of ROOT.
>
> Make sure your image works with the CI, not all images listed in the [rootproject's docker hub](https://hub.docker.com/r/rootproject/root) work 100% of the time.
>
{: .callout}
