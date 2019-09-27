package addons_test

import (
	"io/ioutil"
	"testing"

	"github.com/cf-deployment/units/helpers"
	"gopkg.in/yaml.v2"
)

const testDirectory = "operations/addons"

var addonsTests = map[string]helpers.OpsFileTestParams{}

func TestAddons(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	content, err := ioutil.ReadFile("operations.yml")
	if err != nil {
		t.Fatalf("Error reading operations file: %s", err)
	}
	addonsTests := make(map[string]helpers.OpsFileTestParams)
	yaml.Unmarshal(content, &addonsTests)

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, addonsTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
