package addons_test

import (
	"testing"

	"og/helpers"
)

const testDirectory = "operations/addons"

var addonsTests = map[string]helpers.OpsFileTestParams{
	"component-syslog-custom-ca.yml": {
		Ops:       []string{"enable-component-syslog.yml", "component-syslog-custom-ca.yml"},
		VarsFiles: []string{"example-vars-files/vars-enable-component-syslog.yml"},
	},
	"enable-component-syslog.yml": {
		VarsFiles: []string{"example-vars-files/vars-enable-component-syslog.yml"},
	},
}

func TestAddons(t *testing.T) {
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
			if _, hasTest := addonsTests[fileName]; !hasTest {
				t.Error("Missing test for:", fileName)
			}
		})
	}
	if t.Failed() {
		t.FailNow()
	}

	for name, params := range addonsTests {
		name, params := name, params
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			if err := helpers.CheckInterpolate(cfDeploymentHome, testDirectory, name, params); err != nil {
				t.Error("interpolate failed:", err)
			}
		})
	}
}
