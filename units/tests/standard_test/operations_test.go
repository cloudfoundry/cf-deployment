package standard_test

import (
	"io/ioutil"
	"testing"

	"github.com/cf-deployment/units/helpers"
	"gopkg.in/yaml.v2"
)

const testDirectory = "operations"

func TestStandard(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	content, err := ioutil.ReadFile("operations.yml")
	if err != nil {
		t.Fatalf("Error unmarshalling operations file: %s", err)
	}
	standardTests := make(map[string]helpers.OpsFileTestParams)
	yaml.Unmarshal(content, &standardTests)

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, standardTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
