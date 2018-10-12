package iaas_test

import (
	"testing"

	"tests/helpers"
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

	fileNames, err := helpers.FindFiles(cfDeploymentHome, testDirectory)
	if err != nil {
		t.Fatalf("setup: %v", err)
	}
	for _, fileName := range fileNames {
		t.Run("ensure "+fileName+" has test", func(t *testing.T) {
			// TODO: only skip with some sort of flag
			// t.Skip()
			if _, hasTest := iaasTests[fileName]; !hasTest {
				t.Error("Missing test for:", fileName)
			}
		})
	}
	if t.Failed() {
		t.FailNow()
	}

	for name, params := range iaasTests {
		name, params := name, params
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			if err := helpers.CheckInterpolate(cfDeploymentHome, testDirectory, name, params); err != nil {
				t.Error("interpolate failed:", err)
			}
		})
	}
}
