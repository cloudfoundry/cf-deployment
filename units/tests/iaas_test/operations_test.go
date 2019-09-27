package iaas_test

import (
	"testing"

	"io/ioutil"

	"github.com/cf-deployment/units/helpers"
	"gopkg.in/yaml.v2"
)

const testDirectory = "iaas-support/softlayer"

func TestIAAS(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	content, err := ioutil.ReadFile("operations.yml")
	if err != nil {
		t.Fatalf("Error reading operations file: %s", err)
	}
	iaasTests := make(map[string]helpers.OpsFileTestParams)
	yaml.Unmarshal(content, &iaasTests)

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, iaasTests)
	suite.EnsureTestCoverage(t)
	suite.InterpolateTest(t)
}
