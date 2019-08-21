---
title: "Let's Actually Make A Test (For Real)"
teaching: 5
exercises: 25
objectives:
  - Actually add a test on the output of running physics
questions:
  - I'm out of questions.
  - I've been here too long. Mr. Stark, I don't feel too good.
hidden: false
keypoints:
  - This kind of test is a regression test, as we're testing assuming the code up to this point was correct.
  - This is not a unit test. Unit tests would be testing individual pieces of the `atlas/athena` code-base, or specific functionality you wrote into your algorithms.
---

So at this point, I'm going to be very hands-off, and just explain what you will be doing.

> # Adding a regression test
>
> 1. Add a `test` stage after the `run` stage.
> 2. Add a `test_exotics` job that is part of the `test` stage, and depends on `run_exotics`.
>   - this job does not need to clone the repository (change `GIT_STRATEGY`)
> 3. Create a python file named `test_regression.py` that uses `PyROOT` and `pytest`
>   - you might find the following lines helpful to get `pytest` in the analysisbase image
>     ~~~
>     pip install --user pytest
>     export PATH=/home/atlas/.local/bin:$PATH
>     ~~~
>     {: .source}
> 4. Write a few different tests of your choosing that tests (and asserts) something about `myOuputFile.root`. Some ideas are:
>   - check the structure (does `h_njets_raw` exist?)
>   - check that the integral of a histogram matches a value you expect
>   - check that the bins of a histogram matches the values you expect
> 5. Update your `test_exotics` job to execute `pytest test_regression.py`
> 6. Try causing your CI/CD to fail on the `test_exotics` job
{: .challenge}

Once you're happy with setting up the regression test, mark your merge request as ready by clicking the `Resolve WIP Status` button, and then merge it in to master.

{% include links.md %}
