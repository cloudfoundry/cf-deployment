package standard_test

import (
	"io/ioutil"
	"testing"

	"fmt"

	"github.com/cf-deployment/units/helpers"
	"gopkg.in/yaml.v2"
)

const testDirectory = "operations"

func TestStandard(t *testing.T) {
	content, err := ioutil.ReadFile("operations.yml")
	if err != nil {
		fmt.Printf("Error reading operations file: %s", err)
	}
	standardTests := make(map[string]helpers.OpsFileTestParams)
	yaml.Unmarshal(content, &standardTests)

	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, standardTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
