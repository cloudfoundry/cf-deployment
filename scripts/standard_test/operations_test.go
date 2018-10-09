package standard_test

import (
	"testing"

	"tests/helpers"
)

const testDirectory = "operations"

// TODO: ensure every file in "operations" directory has an entry in the tests array
var standardTests = map[string]helpers.OpsFileTest{
	"aws.yml":                        {},
	"azure.yml":                      {},
	"bosh-lite.yml":                  {},
	"cf-syslog-skip-cert-verify.yml": {},
	"configure-confab-timeout.yml": {
		Vars: []string{"confab_timeout=60"},
	},
	"use-offline-windows2016fs.yml": {
		Ops: []string{"windows2016-cell.yml", "use-offline-windows2016fs.yml"},
	},
	"enable-nfs-ldap.yml": {
		Ops:       []string{"enable-nfs-volume-service.yml", "enable-nfs-ldap.yml"},
		VarsFiles: []string{"example-vars-files/vars-enable-nfs-ldap.yml"},
	},
}

func TestStandard(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Errorf("setup: %v", err)
	}

	fileNames, _ := helpers.FindFiles(cfDeploymentHome, testDirectory)
	for _, fileName := range fileNames {
		t.Run(fileName+" has test", func(t *testing.T) {
			t.Skip()
			if _, hasTest := standardTests[fileName]; !hasTest {
				t.Error("Missing test for:", fileName)
			}
		})
	}
	if t.Failed() {
		t.FailNow()
	}

	for name, params := range standardTests {
		name, params := name, params
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			if err := helpers.CheckInterpolate(cfDeploymentHome, testDirectory, name, params); err != nil {
				t.Error("interpolate failed:", err)
			}
		})
	}
}
