---
title: "Introduction"
teaching: 5
exercises: 0
questions:
- What is continuous integration / continuous deployment?
objectives:
- Understand why CI/CD is important
- Learn what can be possible with CI/CD
- Find resources to explore in more depthg
keypoints:
- CI/CD is crucial for any reproducibility and testing
- Take advantage of automation to reduce your workload
---
<iframe width="420" height="263" src="https://www.youtube.com/embed/dTuVEL5-sSw?list=PLKZ9c4ONm-VmmTObyNWpz4hB3Hgx8ZWSb" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
# What is CI/CD?

Continuous Integration (CI) is the concept of literal continuous integration of code changes. That is, every time a contributor (student, colleague, random bystander) provides new changes to your codebase, those changes are tested to make sure they don't "break" anything. Continuous Deployment (CD), similarly, is the literal continuous deployment of code changes. That means that, assuming the CI passes, you'd like to automatically deploy those changes.

> ## Catch and Release
>
> This is just like a fishing practice for ~~conservation~~ preservation!
> <center><iframe src="https://giphy.com/embed/j8080dkr0ux1e" width="385" height="480" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/funny-girl-fishing-j8080dkr0ux1e">via GIPHY</a></p></center>
{: .callout}

## Breaking Changes

What does it even mean to "break" something? The idea of "breaking" something is pretty contextual. If you're working on C++ code, then you probably want to make sure things compile and run without segfaulting at the bare minimum. If it's python code, maybe you have some tests with `pytest` that you want to make sure pass ("exit successfully"). Or if you're working on a paper draft, you might check for grammar, misspellings, and that the document compiles from LaTeX. Whatever the use-case is, integration is about **catching** breaking changes.

## Deployment

Similarly, "deployment" can mean a lot of things. Perhaps you have a Curriculum Vitae (CV) that is automatically built from LaTeX and uploaded to your website. Another case is to release docker images of your framework that others depend on. Maybe it's just uploading documentation. Or to even upload a new tag of your python package on `pypi`. Whatever the use-case is, deployment is about **releasing** changes.

## Workflow Automation

CI/CD is the first step to automating your entire workflow. Imagine everything you do in order to run an analysis, or make some changes. Can you make a computer do it automatically? If so, do it! The less human work you do, the less risk of making human mistakes.


> ## Anything you can do, a computer can do better
>
> Any command you run on your computer can be equivalently run in a CI job.
{: .callout}

Don't just limit yourself to thinking of CI/CD as primarily for testing changes, but as one part of automating an entire development cycle. You can trigger notifications to your cellphone, fetch/download new data, execute cron jobs, and so much more. However, for the lessons you'll be going through today and that you've just recently learned about python testing with `pytest`, we'll focus primarily on setting up CI/CD with tests for code that you've written already.

# CI/CD Solutions

Now, obviously, we're not going to make our own fully-fledged CI/CD solution. Plenty exist in the wild today, and below are just a popular few:

- [Native GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [Native GitHub CI/CD](https://github.com/features/actions)
- [Travis CI](https://travis-ci.org/)
- [Circle CI](https://circleci.com/)
- [TeamCity](https://www.jetbrains.com/teamcity/)
- [Bamboo](https://www.atlassian.com/software/bamboo)
- [Jenkins](https://jenkins.io/)
- [Buddy](https://buddy.works/)
- [CodeShip](https://codeship.com/)
- [CodeFresh](https://g.codefresh.io/)

For today's lesson, we'll only focus on GitLab's solution. However, be aware that all the concepts you'll be taught today: including pipelines, stages, jobs, artifacts; all exist in other solutions by similar/different names. For example, GitLab supports two features known as caching and artifacts; but Travis doesn't quite implement the same thing for caching and has no native support for artifacts. Therefore, while we don't discourage you from trying out other solutions, there's no "one size fits all" when designing your own CI/CD workflow.

{% include links.md %}
