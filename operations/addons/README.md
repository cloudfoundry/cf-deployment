# cf-deployment Addons Ops-files
The opsfiles in this directory
can be applied to both
[runtime configs][runtime-config-docs] and
manifests.

- For General Ops-files, check out the [Ops-file README](../README.md).
- For Backup and Restore Ops-files (for configuring your deployment for use with [BBR](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore)), checkout the [Backup and Restore Ops-files README](../backup-and-restore/README.md).
- For Community Ops-files, check out the [Community Ops-file README](../community/README.md).
- For Experimental Ops-files, check out the [Experimental Ops-file README](../experimental/README.md).

We recommend the use
of runtime configs
for cross-cutting concerns
related to multiple deployments.

Some deployers may prefer
to apply these opsfiles
to their manifests
for automation or CI.

## Addons
BOSH allows operators to add jobs
to VMs via the use of [addons][addons-docs].

| Name | Purpose | Notes |
|:---  |:---     |:---   |
| [`component-syslog-custom-ca.yml`](component-syslog-custom-ca.yml) | The syslog_forwarder job will only trust certs signed by the provided cert chain. | Requires `enable-component-syslog.yml`. Not necessary if syslog target has a cert signed by a public CA. |
| [`enable-component-syslog.yml`](enable-component-syslog.yml) | This collocates a job from [syslog release][syslog-release-repo] to forward local syslog events in RFC5424 format to a remote syslog endpoint. | Uses rsyslog, which is available on the stemcell. Further documentation of the `custom_rule` property can be found [here][syslog-custom-rule-examples]. For the windows equivalent, see `operations/experimental/windows-enable-component-syslog.yml`. Requires that target have a valid cert. To configure a custom CA, use `component-syslog-custom-ca.yml`. |

## Adding a Runtime Config
To add a runtime config to a director for the first time,
use `bosh update-runtime-config`.
This allows the use of the `-v` flag
to provide values,
or the `-l` flag to load values from a file.

See the runtime configs themselves
to determine which values you need to provide.

You will need to `bosh deploy`
in order for changes to affect VMs
whenever the runtime config is updated.

## Managing Runtime Configuration
At the moment,
a BOSH Director has only one runtime config.
This means that if you wish to add
to an existing runtime config,
you need to download it with `bosh runtime-config`,
extend it manually,
and then use `bosh update-runtime-config`
to set your extended config on the director.

If you just set the runtime config directly,
please be aware that it will overwrite any existing runtime config.

Similarly, to remove a runtime config,
you must "update" the director
with an empty runtime config.

[runtime-config-docs]: https://bosh.io/docs/runtime-config.html
[syslog-custom-rule-examples]: https://github.com/cloudfoundry/syslog-release/blob/develop/examples/example-custom-rules.md
[syslog-release-repo]: https://github.com/cloudfoundry/syslog-release
[addons-docs]: http://bosh.io/docs/runtime-config.html#addons
