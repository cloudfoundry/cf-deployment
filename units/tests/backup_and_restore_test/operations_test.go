package backupandrestore_test

import (
	"io/ioutil"
	"testing"

	"github.com/cf-deployment/units/helpers"
	"gopkg.in/yaml.v2"
)

const testDirectory = "operations/backup-and-restore"

func TestBackupAndRestore(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	content, err := ioutil.ReadFile("operations.yml")
	if err != nil {
		t.Fatalf("Error reading operations file: %s", err)
	}
	backupAndRestoreTests := make(map[string]helpers.OpsFileTestParams)
	yaml.Unmarshal(content, &backupAndRestoreTests)

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, backupAndRestoreTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
