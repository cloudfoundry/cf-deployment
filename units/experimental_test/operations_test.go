package experimental_test

import (
	"testing"

	"github.com/cf-deployment/units/helpers"
)

const testDirectory = "operations/experimental"

var experimentalTests = map[string]helpers.OpsFileTestParams{
	"add-credhub-lb.yml":         {},
	"add-deployment-updater.yml": {},
	"add-deployment-updater-external-db.yml": {
		Ops:       []string{"add-deployment-updater.yml", "../use-external-dbs.yml", "add-deployment-updater-external-db.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-external-dbs.yml"},
	},
	"add-deployment-updater-postgres.yml": {
		Ops: []string{"add-deployment-updater.yml", "../use-postgres.yml", "add-deployment-updater-postgres.yml"},
	},
	"add-metric-store.yml": {},
	"add-syslog-agent.yml": {},
	"add-syslog-agent-windows1803.yml": {
		Ops: []string{"../windows1803-cell.yml", "add-syslog-agent.yml", "add-syslog-agent-windows1803.yml"},
	},
	"add-system-metrics-agent.yml": {},
	"add-system-metrics-agent-windows1803.yml": {
		Ops: []string{"../windows1803-cell.yml", "add-system-metrics-agent.yml", "add-system-metrics-agent-windows1803.yml"},
	},
	"deploy-forwarder-agent.yml":               {},
	"disable-interpolate-service-bindings.yml": {},
	"enable-bpm-garden.yml":                    {},
	"enable-iptables-logger.yml":               {},
	"enable-mysql-tls.yml":                     {},
	"enable-nfs-volume-service-credhub.yml":    {},
	"enable-oci-phase-1.yml":                   {},
	"enable-routing-integrity-windows1803.yml": {
		Ops: []string{"../windows1803-cell.yml", "enable-routing-integrity-windows1803.yml"},
	},
	"enable-routing-integrity-windows2016.yml": {
		Ops: []string{"../windows2016-cell.yml", "enable-routing-integrity-windows2016.yml"},
	},
	"enable-smb-volume-service.yml":            {},
	"enable-suspect-actual-lrp-generation.yml": {},
	"enable-tls-cloud-controller-postgres.yml": {
		Ops: []string{"../use-postgres.yml", "enable-tls-cloud-controller-postgres.yml"},
	},
	"enable-traffic-to-internal-networks.yml":  {},
	"fast-deploy-with-downtime-and-danger.yml": {},
	"infrastructure-metrics.yml":               {},
	"migrate-nfsbroker-mysql-to-credhub.yml": {
		Ops:       []string{"../enable-nfs-volume-service.yml", "migrate-nfsbroker-mysql-to-credhub.yml"},
		VarsFiles: []string{"../example-vars-files/vars-migrate-nfsbroker-mysql-to-credhub.yml"},
	},
	"perm-service.yml": {
		Ops:  []string{"enable-mysql-tls.yml", "perm-service.yml"},
		Vars: []string{"perm_uaa_clients_cc_perm_secret=perm_secret", "perm_uaa_clients_perm_monitor_secret=perm_monitor_secret"},
	},
	"perm-service-with-pxc-release.yml": {
		Ops:  []string{"perm-service.yml", "../use-pxc.yml", "perm-service-with-pxc-release.yml"},
		Vars: []string{"perm_uaa_clients_cc_perm_secret=perm_secret", "perm_uaa_clients_perm_monitor_secret=perm_monitor_secret"},
	},
	"perm-service-with-tcp-routing.yml": {
		Ops:  []string{"perm-service.yml", "../use-pxc.yml", "perm-service-with-pxc-release.yml", "perm-service-with-tcp-routing.yml"},
		Vars: []string{"perm_uaa_clients_cc_perm_secret=perm_secret", "perm_uaa_clients_perm_monitor_secret=perm_monitor_secret"},
	},
	"rootless-containers.yml": {},
	"set-cpu-weight.yml":      {},
	"use-compiled-releases-windows.yml": {
		Ops: []string{"../use-compiled-releases.yml", "../windows2012R2-cell.yml", "use-compiled-releases-windows.yml"},
	},
	"use-create-swap-delete-vm-strategy.yml":          {},
	"use-logcache-for-cloud-controller-app-stats.yml": {},
	"use-native-garden-runc-runner.yml":               {},
	"windows-component-syslog-ca.yml": {
		Ops:       []string{"windows-enable-component-syslog.yml", "windows-component-syslog-ca.yml"},
		VarsFiles: []string{"../addons/example-vars-files/vars-enable-component-syslog.yml"},
	},
	"windows-enable-component-syslog.yml": {
		Ops:       []string{"windows-enable-component-syslog.yml"},
		VarsFiles: []string{"../addons/example-vars-files/vars-enable-component-syslog.yml"},
	},
}

func TestExperimental(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, experimentalTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
