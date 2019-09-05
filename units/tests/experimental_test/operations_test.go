package experimental_test

import (
	"testing"

	"github.com/cf-deployment/units/helpers"
)

const testDirectory = "operations/experimental"

var experimentalTests = map[string]helpers.OpsFileTestParams{
	"add-credhub-lb.yml":   {},
	"add-metric-store.yml": {},
	"add-syslog-agent.yml": {},
	"add-syslog-agent-windows1803.yml": {
		Ops: []string{"../windows1803-cell.yml", "add-syslog-agent.yml", "add-syslog-agent-windows1803.yml"},
	},
	"add-system-metrics-agent.yml": {},
	"add-system-metrics-agent-windows1803.yml": {
		Ops: []string{"../windows1803-cell.yml", "add-system-metrics-agent.yml", "add-system-metrics-agent-windows1803.yml"},
	},
	"disable-interpolate-service-bindings.yml":                 {},
	"disable-uaa-client-redirect-uri-legacy-matching-mode.yml": {},
	"enable-bpm-garden.yml":                                    {},
	"enable-containerd-for-processes.yml":                      {},
	"enable-iptables-logger.yml":                               {},
	"enable-oci-phase-1.yml":                                   {},
	"enable-nginx-routing-integrity-windows2019.yml": {
		Ops: []string{"../windows2019-cell.yml", "enable-nginx-routing-integrity-windows2019.yml"},
	},
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
	"rootless-containers.yml":                  {},
	"set-cpu-weight.yml":                       {},
	"set-cpu-weight-windows1803.yml": {
		Ops: []string{"../windows1803-cell.yml"},
	},
	"set-cpu-weight-windows2019.yml": {
		Ops: []string{"../windows2019-cell.yml"},
	},
	"use-compiled-releases-windows.yml": {
		Ops: []string{"../use-compiled-releases.yml", "../windows2012R2-cell.yml", "use-compiled-releases-windows.yml"},
	},
	"use-create-swap-delete-vm-strategy.yml":          {},
	"use-logcache-for-cloud-controller-app-stats.yml": {},
	"use-logcache-syslog-ingress.yml": {
		Ops: []string{"add-syslog-agent.yml", "use-logcache-syslog-ingress.yml"},
	},
	"use-logcache-syslog-ingress-windows1803.yml": {
		Ops: []string{"../windows1803-cell.yml", "add-syslog-agent.yml", "add-syslog-agent-windows1803.yml", "use-logcache-syslog-ingress.yml", "use-logcache-syslog-ingress-windows1803.yml"},
	},
	"use-native-garden-runc-runner.yml": {},
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
