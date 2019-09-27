package bitsservice_test

import (
	"io/ioutil"
	"testing"

	"github.com/cf-deployment/units/helpers"
	"gopkg.in/yaml.v2"
)

const testDirectory = "operations/bits-service"

func TestBitSservice(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	content, err := ioutil.ReadFile("operations.yml")
	if err != nil {
		t.Fatalf("Error reading operations file: %s", err)
	}
	bitsServiceTests := make(map[string]helpers.OpsFileTestParams)
	yaml.Unmarshal(content, &bitsServiceTests)

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, bitsServiceTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
