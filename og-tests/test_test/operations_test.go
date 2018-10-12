package test_test

import (
	"testing"

	"og/helpers"
)

const testDirectory = "operations/test"

var testTests = map[string]helpers.OpsFileTestParams{
	"add-datadog-firehose-nozzle.yml": {
		Vars: []string{"datadog_api_key=XYZ", "datadog_metric_prefix=foo.bar", "traffic_controller_external_port=8443"},
	},
	"add-oidc-provider.yml": {},
	"add-persistent-isolation-segment-diego-cell-bosh-lite.yml": {
		Ops: []string{"add-persistent-isolation-segment-diego-cell.yml", "add-persistent-isolation-segment-diego-cell-bosh-lite.yml"},
	},
	"add-persistent-isolation-segment-diego-cell.yml": {},
	"add-persistent-isolation-segment-router.yml":     {},
	"alter-ssh-proxy-redirect-uri.yml":                {},
	"disable_windows_consul_agent_nameserver_overwriting.yml": {
		Ops: []string{"../windows2012R2-cell.yml", "disable_windows_consul_agent_nameserver_overwriting.yml"},
	},
	"windows2016-debug.yml": {
		Ops: []string{"../windows2012R2-cell.yml"},
	},
}

func TestTest(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	fileNames, err := helpers.FindFiles(cfDeploymentHome, testDirectory)
	if err != nil {
		t.Fatalf("setup: %v", err)
	}
	for _, fileName := range fileNames {
		t.Run("ensure "+fileName+" has test", func(t *testing.T) {
			// TODO: only skip with some sort of flag
			// t.Skip()
			if _, hasTest := testTests[fileName]; !hasTest {
				t.Error("Missing test for:", fileName)
			}
		})
	}
	if t.Failed() {
		t.FailNow()
	}

	for name, params := range testTests {
		name, params := name, params
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			if err := helpers.CheckInterpolate(cfDeploymentHome, testDirectory, name, params); err != nil {
				t.Error("interpolate failed:", err)
			}
		})
	}
}
