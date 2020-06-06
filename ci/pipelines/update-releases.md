# update-releases

Notes on the design of this pipeline are [here](https://miro.com/app/board/o9J_kxEuPlE=/) and [here](https://miro.com/app/board/o9J_kyXYXXo=/).

## Groups

All groups pull from the same "pre-dev" pool of 4 environents.  "pre-dev" stands for "pre-develop"; i.e. these pipelines are verifying changes are safe to merge into develop.

_Given these environments are pooled when you need to re-run a job then the acquire lock jobs is the correct point of entry, not the failed job._

* update-linux-stemcell; note that major and minor stemcell bumps are handled differently.  Major stemcell bumps; e.g. a kernel bump, recompile all bosh releases.  Minors do not.  Deploys and run cf-d smoke tests.

* update-base-release; tests new releases of any bosh component that is in the base cf-deployment.yml.  Deploys and runs cf-d smoke tests. 

* update-ops-release; tests new releases of any bosh component that is in any ops file.  Deploys and runs cf-d smoke tests.

* update-windows-stemcells-and-releases; bump the stemcell or component on develop.

* debug; by default component bumps that fail will throw away their pooled environment.  It is possible to put a component in debug mode so that the environment is kept on failure and if done the pipeline will be shown here.  A component can be put in debug mode by specifying `debug: true` in [this file](https://github.com/cloudfoundry/cf-deployment/blob/develop/ci/input/inputs.yml)

* cleanup; when a component bump fails the changes are placed onto a branch.  This group cleans up these branches when they get old. 

* infrastructure; update-linux-stemcell pipeline uses a long-lived bbl environment managed by this infrastructure pipeline




 



 