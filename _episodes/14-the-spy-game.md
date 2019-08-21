---
title: "Getting into the Spy Game"
teaching: 5
exercises: 5
objectives:
  - Add custom environment variables
  - Learn how to give your CI/CD Runners access to private information
questions:
  - How can I give my CI job private information?
hidden: false
keypoints:
  - Service accounts provide an extra layer of security between the outside world and your account
  - Environment variables in GitLab CI/CD allow you to hide protected information from others who can see your code
---

So we're nearly done with getting the merge request for the CI/CD up and running but we need to deal with this error:

~~~
$ AnalysisPayload root://eosuser.cern.ch//eos/user/g/gstark/public/DAOD_EXOT27.17882744._000026.pool.root.1 1000
xAOD::Init                INFO    Environment initialised for data access
TNetXNGFile::Open         ERROR   [ERROR] Server responded with an error: [3010] Unable to give access - user access restricted - unauthorized identity used ; Permission denied

Warning in <xAOD::TReturnCode>:
Warning in <xAOD::TReturnCode>: Unchecked return codes encountered during the job
Warning in <xAOD::TReturnCode>: Number of unchecked successes: 1
Warning in <xAOD::TReturnCode>: To fail on an unchecked code, call xAOD::TReturnCode::enableFailure() at the job's start
Warning in <xAOD::TReturnCode>:
ERROR: Job failed: exit code 1
~~~
{: .output}

# Access Control

So we need to give our CI/CD access to our data. This is actually a good thing. It means CMS can't just grab it! Anyhow, this is done by pretty much done by executing `echo $SERVICE_PASS | kinit $CERN_USER` assuming that we've set the corresponding environment variables.

> ## Service Account or Not?
>
> When you're dealing with a personal repository (project) that nobody else has administrative access to, e.g. the settings, then it's *ok* to use your CERN account/password in the environment variables for the settings...
>
> However, when you're sharing or part of a group, it is much better to use a group's service account or a user's (maybe yours) service account for authentication instead. For today's lesson however, we'll be using your account and show pictures of how to set these environment variables.
{: .callout}

## Variables

There are two kinds of environment variables:
- predefined
- custom

Additionally, you can specify that the variable is a `file` type which is useful for passing in private keys to the CI/CD Runners. Variables can be added globally or per-job using the `variables` parameter.

### Predefined Variables

There are quite a lot of [predefined variables](https://gitlab.cern.ch/help/ci/variables/predefined_variables.md). We won't cover these in depth but link for reference as they're well-documented in the GitLab docs.

### Custom Variables

Let's go ahead and add some custom variables to fix up our access control.

1. Navigate to the `Settings -> CI/CD` of your repository
  ![CI/CD Repo Settings]({{site.baseurl}}/fig/repo-settings-ci-cd.png)
2. Expand the `Variables` section on this page by clicking `Expand`
  ![CI/CD Variables Click Expand]({{site.baseurl}}/fig/repo-settings-ci-cd-variables-click-expand.png)
3. Specify two environment variables, `SERVICE_PASS` and `CERN_USER`, and fill them in appropriately. (If possible, mask the password).
  ![CI/CD Variables Specified]({{site.baseurl}}/fig/repo-settings-ci-cd-variables-specified.png)
4. Click to save the variables.

> ## DON'T PEEK
>
> DON'T PEEK AT YOUR FRIEND'S SCREEN WHILE DOING THIS.
{: .testimonial}

# Adding `kinit` for access control

Now it's time to update your CI/CD to use the environment variables you defined by adding `echo $SERVICE_PASS | kinit $CERN_USER` as part of the `before_script` to the `run_exotics` job as that's the job that requires access.

# Adding Artifacts on Success

As it seems like we have a complete CI/CD that does physics - we should see what came out. We just need to add artifacts for the `run_exotics` job. This is left as an exercise to you.

> ## Adding Artifacts
>
> Let's add `artifacts` to our `run_exotics` job to save the `run` directory. Let's have the artifacts expire in a week instead.
>
> > ## Solution
> > ~~~
> > run_exotics:
> >   stage: run
> >   image: atlas/analysisbase:21.2.85-centos7
> >   dependencies:
> >     - build
> >   before_script:
> >     - source /home/atlas/release_setup.sh
> >     - source build/${AnalysisBase_PLATFORM}/setup.sh
> >     - echo $SERVICE_PASS | kinit $CERN_USER
> >   script:
> >     - mkdir run
> >     - cd run
> >     - AnalysisPayload root://eosuser.cern.ch//eos/user/g/gstark/public/DAOD_EXOT27.17882744._000026.pool.root.1 1000
> >   artifacts:
> >     paths:
> >       - run
> >     expire_in: 1 week
> > ~~~
> > {: .language-yaml}
> {: .solution}
{: .challenge}

> ## Further Reading
> - [https://gitlab.cern.ch/help/ci/variables/README#variables](https://gitlab.cern.ch/help/ci/variables/README#variables)
> - [https://gitlab.cern.ch/help/ci/variables/predefined_variables.md](https://gitlab.cern.ch/help/ci/variables/predefined_variables.md)
{: .checklist}

{% include links.md %}
