package iaas_test

import (
	"testing"

	"github.com/cf-deployment/units/helpers"
)

const testDirectory = "iaas-support/softlayer"

var iaasTests = map[string]helpers.OpsFileTestParams{
	"add-system-domain-dns-alias.yml": {
		Vars: []string{"system_domain=my.domain"},
	},
}

func TestIAAS(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, iaasTests)
	suite.EnsureTestCoverage(t)
	suite.InterpolateTest(t)
}
