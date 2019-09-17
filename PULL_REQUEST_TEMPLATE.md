## Please take a moment to review the questions before submitting the PR

🚫 We only accept PRs to develop branch. If this is an exception, please specify why 🚫

### WHAT is this change about?

> _Please describe the change._

### What customer problem is being addressed? Use customer persona to define the problem e.g. Alana is unable to...

> _Understanding why this change is being made is fantastically helpful. Please do tell..._

### Please provide any contextual information.

> _Include any links to other PRs, stories, slack discussions, etc... that will help establish context._

### Has a cf-deployment including this change passed [cf-acceptance-tests](https://github.com/cloudfoundry/cf-acceptance-tests)?

- [ ] YES
- [ ] NO

### Does this PR introduce a breaking change? Please take a moment to read through the examples before answering the question.

- [ ] YES - please choose the category from below. Feel free to provide additional details.
- [ ] NO

> **Types of breaking changes:**
> 1. **causes app or operator downtime**
> 2. increases VM footprint of cf-deployment - e.g. new jobs, new add ons, increases # of instances etc.
> 3. modifies, deletes or moves the name of a job or instance group in the main manifest
> 4. modifies the name or deletes a property of a job or instance group in the main manifest
> 5. changes the name of credentials in the main manifest
> 6. requires out-of-band manual intervention on the part of the operator 
> 7. modifies the ops-file path, changes the type, changes the values or removes ops-files from the followning folders
>    - `./operations/` or `./operations/experimental` 
>    - `./addons`
>    - `./backup-and-restore/`
>    - `./bits-service/`
>
> _If you're promoting an experimental Ops-file (or removing one), Please follow the [Ops-file workflows](https://github.com/cloudfoundry/cf-deployment/blob/master/ops-file-promotion-workflow.md)._

> Ops files changes in the following folders are considered as NON BREAKING CHANGES
> `./community`, `./example-vars-files`, `./test/`, `./workaround`

### How should this change be described in cf-deployment release notes?

> _Something brief that conveys the change and is written with the **persona (Alana, Cody...)** in mind. See [previous release notes](https://github.com/cloudfoundry/cf-deployment/releases) for examples._

### Does this PR introduce a new BOSH release into the base cf-deployment.yml manifest or any ops-files?

- [ ] YES - please specify
- [ ] NO

### Does this PR make a change to an experimental or GA'd feature/component?

- [ ] experimental feature/component
- [ ] GA'd feature/component

### Please provide Acceptance Criteria for this change?

> _Please specify either bosh cli or cf cli commands for our team (and cf operators) to verify the changes._

> _Few examples_
> 1. For a PR with a new job in the manifest, `bosh instances` can verify the job is running after upgrade. You can provide additional commands to verify the job is running as specified.
> 2. For a PR with new variables, `bosh variables | grep <var-name>` command can verify the variable exists. This is the simplest varification but you can also provide additional commands to test that the variable holds the desired value.

### What is the level of urgency for publishing this change?

- [ ] **Urgent** - unblocks current or future work
- [ ] **Slightly Less than Urgent**

### Tag your pair, your PM, and/or team!

> _It's helpful to tag a few other folks on your team or your team alias in case we need to follow up later._
