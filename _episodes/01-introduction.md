---
title: "Introduction"
teaching: 5
exercises: 0
questions:
- What is continuous integration / continuous deployment?
objectives:
- Understand why CI/CD is important
- Learn what can be possible with CI/CD
- Find resources to explore in more depth
keypoints:
- CI/CD is crucial for any reproducibility and testing
- Take advantage of automation to reduce your workload
---
# What is CI/CD?

Continuous Integration (CI) is the concept of literal continuous integration of code changes. That is, every time a contributor (student, colleague, random bystander) provides new changes to your codebase, those changes are tested to make sure they don't "break" anything. Continuous Deployment, similarly, is the literal continuous deployment of code changes. That means that, assuming the CI passes, you'd like to automatically deploy those changes.

> ## Catch and Release
>
> This is just like a fishing practice for conservation (read: preservation)!
{: .callout}

## Breaking Changes

What does it even mean to "break" something? The idea of "breaking" something is pretty contextual. If you're working on C++ code, then you probably want to make sure things compile and run without segfaulting at the bare minimum. If it's python code, maybe you have some tests with `pytest` that you want to make sure pass ("exit successfully"). Or if you're working on a paper draft, you might check for grammar, misspellings, and that the document compiles from LaTeX. Whatever the use-case is, integration is about **catching** breaking changes.

## Deployment

Similarly, "deployment" can mean a lot of things. Perhaps you have a Curriculum Vitae (CV) that is automatically built from LaTeX and uploaded to your website. Another case is to release docker images of your framework that others depend on. Maybe it's just uploading documentation. Or to even upload a new tag of your python package on `pypi`. Whatever the use-case is, deployment is about **releasing** changes.

{% include links.md %}

