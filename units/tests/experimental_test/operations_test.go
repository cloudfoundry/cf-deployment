package experimental_test

import (
	"io/ioutil"
	"testing"

	"github.com/cf-deployment/units/helpers"
	"gopkg.in/yaml.v2"
)

const testDirectory = "operations/experimental"

var experimentalTests = map[string]helpers.OpsFileTestParams{}

func TestExperimental(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	content, err := ioutil.ReadFile("operations.yml")
	if err != nil {
		t.Fatalf("Error reading operations file: %s", err)
	}
	experimentalTests := make(map[string]helpers.OpsFileTestParams)
	yaml.Unmarshal(content, &experimentalTests)

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, experimentalTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
