---
title: "Being Assertive"
teaching: 5
exercises: 5
objectives:
  - Understand how assertions in python correspond to exit codes
  - Figure out how pytest fits in
questions:
  - What happens with assertions in python?
hidden: false
keypoints:
  - You can do whatever you like in a test, as long as you return the right exit code
  - Pytest, and other test utilities, will propagate the exit codes correctly
---

This is a relatively short section, but we need to connect some things you've learned from testing in python with exit codes.

# Assert Your Tests

Recall in the previous session, you made a `test_mean.py` that asserted lots of statements. For example `assert obs == exp`. What happens when an assertion fails in python? An exception is raised, `AssertionError`. The nice thing about python is that all unhandled exceptions return a non-zero exit code. If an exit code is not set, this defaults to `1`. Let's just quickly do a sanity check with `python -c` which allows for executing arbitrary python commands.

~~~
> python -c "assert True"
> echo $?
0
> python -c "assert False"
Traceback (most recent call last):
  File "<string>", line 1, in <module>
AssertionError
> echo $?
1
~~~
{: .source}

Ignoring what would cause the assertion to be `True` or `False`, we can see that assertions automatically indicate failure in a script.

# What about pytest?

Pytest, thankfully, handles these assertion failures intuitively. That is, running `pytest test_mean.py` will produce an expected exit code depending on whether the test passed or failed. To try this out quickly, go ahead and create a file called `test_assert.py` with the following:

~~~
def test_assert_success():
  assert True

def test_assert_failure():
  assert False
~~~
{: .language-python}

and then running `pytest test_assert.py` followed up with `echo $?`, you should be able to confirm that the exit codes are useful here.

{% include links.md %}
