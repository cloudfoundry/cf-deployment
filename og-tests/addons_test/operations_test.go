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
	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, addonsTests)
	suite.EnsureHasTest(t)
	suite.InterpolateTest(t)
}
