# cf-deployment

## Groups

* fr; tests a fresh install
* up; test upgrade
* ex; tests expermiental ops files
* li; tests bosh-lite
* bbr; test bbr
* st; tests stability of cf-d and CATs over time
* ship-it; PM uses to ship cf-d

## Notes

* branch-freshness; ensure branches of cf-d don't go stale
* *-release-pool-manual; jobs that will release the lock on the environment in question.  Only visible via group.  Used to reset the pipeline.
