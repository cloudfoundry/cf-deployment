package iaas_test

import (
	"testing"

	"github.com/cf-deployment/units/helpers"
)

const testDirectory = "iaas-support/softlayer"

func TestIAAS(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory)
	suite.LoadTestOperationsYaml(t)
	suite.EnsureTestCoverage(t)
	suite.InterpolateTest(t)
}
