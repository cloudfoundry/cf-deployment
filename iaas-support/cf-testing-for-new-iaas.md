## CF testing for New IaaS
The intended audience for this document are potential IaaS partners that want to enable the deployment of Cloud Foundry on their IaaS. 
Fulfilling the requirements outlined below will provide visibility into the maturity and stability of a prospective IaaS with regards to the deployment of BOSH and a Cloud Foundry foundation. 

1. The partner must maintain two publicly accessible CI pipelines
   - One pipeline should deploy BOSH fresh via bosh-deployment, deploy a foundation fresh via [cf-deployment](https://github.com/cloudfoundry/cf-deployment) [1], run a subset of [`cf-acceptance-tests` (CATs)](https://github.com/cloudfoundry/cf-acceptance-tests) [2], and then tear down CF and BOSH via BOSH commands
   - The other pipeline should execute the initial deploy or upgrade BOSH idempotently via bosh-deployment, deploy or upgrade CFAR idempotently via cf-deployment [1], and run the same subset of CATs [2]
1. Any update to upstream bosh-deployment repo, cf-deployment repo, partner CPI, stemcell, or CATs repo should trigger new runs of both pipelines
1. Additionally, the pipelines should both be triggered every day even if none of the pipeline inputs has changed, to ensure sufficient data to assess platform stability
1. Stability will be determined by a success rate greater than or equal to 86% of all BOSH deployment, CF deployment, and CATs runs over the trailing 1 month

**[1]** cf-deployment should be deployed with no modifications or ops-files, aside from IaaS-specific modifications such as using the IaaS’s blobstore or RDBMS service; the ops-files used for the above modifications must be publicly available for review by core CFF development teams.

**[2]** A config file controls which CATs tests are run. The [example config](https://github.com/cloudfoundry/cf-acceptance-tests/blob/main/example-cats-config.json) in the CATs GitHub repo will configure CATs to run the subset of tests required here. 
In addition to using the example configuration provided, CATs must be run via ginkgo with no flake attempts. 
