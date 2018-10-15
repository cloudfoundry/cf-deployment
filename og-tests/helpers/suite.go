package helpers

import "testing"

type SuiteTest struct {
	homeDir string
	testDir string

	tests map[string]OpsFileTestParams
}

func NewSuiteTest(cfDeploymentHome, testSubDirectory string, opsTests map[string]OpsFileTestParams) SuiteTest {
	return SuiteTest{
		homeDir: cfDeploymentHome,
		testDir: testSubDirectory,
		tests:   opsTests,
	}
}

func (suite SuiteTest) EnsureHasTest(t *testing.T) {
	t.Helper()

	fileNames, err := findFiles(suite.homeDir, suite.testDir)
	if err != nil {
		t.Fatalf("setup: find files: %v", err)
	}

	for _, fileName := range fileNames {
		t.Run("ensure "+fileName+" has test", func(t *testing.T) {
			// TODO: only skip with some sort of flag
			// t.Skip()
			if _, hasTest := suite.tests[fileName]; !hasTest {
				t.Error("Missing test for:", fileName)
			}
		})
	}

	if t.Failed() {
		t.FailNow()
	}
}

func (suite SuiteTest) InterpolateTest(t *testing.T) {
	t.Helper()

	for name, params := range suite.tests {
		t.Run(name, suite.checkInterpolate(name, params))
	}
}

func (suite SuiteTest) checkInterpolate(name string, options OpsFileTestParams) func(*testing.T) {
	return func(t *testing.T) {
		t.Helper()
		t.Parallel()

		if err := checkInterpolate(suite.homeDir, suite.testDir, name, options); err != nil {
			t.Error("interpolate failed:", err)
		}
	}
}
