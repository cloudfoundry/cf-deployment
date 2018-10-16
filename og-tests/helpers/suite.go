package helpers

import (
	"fmt"
	"io/ioutil"
	"path/filepath"
	"regexp"
	"testing"
)

type SuiteTest struct {
	homeDir    string
	testSubDir string

	tests map[string]OpsFileTestParams
}

func NewSuiteTest(cfDeploymentHome, testSubDirectory string, opsTests map[string]OpsFileTestParams) SuiteTest {
	return SuiteTest{
		homeDir:    cfDeploymentHome,
		testSubDir: testSubDirectory,
		tests:      opsTests,
	}
}

func (suite SuiteTest) EnsureTestCoverage(t *testing.T) {
	t.Helper()

	fileNames, err := findFiles(suite.homeDir, suite.testSubDir)
	if err != nil {
		t.Fatalf("setup: find files: %v", err)
	}

	for _, fileName := range fileNames {
		t.Run(fmt.Sprintf("ensure %s has test coverage", fileName), func(t *testing.T) {
			// TODO: only skip with some sort of flag
			// t.Skip()
			if _, hasTest := suite.tests[fileName]; !hasTest {
				t.Errorf("%s has no test", fileName)
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

		if err := checkInterpolate(suite.homeDir, suite.testSubDir, name, options); err != nil {
			t.Error("interpolate failed:", err)
		}
	}
}

func (suite SuiteTest) EnsureOpsFileInReadme(t *testing.T) {
	t.Helper()

	fileNames, err := findFiles(suite.homeDir, suite.testSubDir)
	if err != nil {
		t.Fatalf("setup: find files: %v", err)
	}

	readmePath := filepath.Join(suite.homeDir, suite.testSubDir, "README.md")
	readmeContents, err := ioutil.ReadFile(readmePath)
	if err != nil {
		t.Fatalf("setup: load README: %v", err)
	}

	for _, fileName := range fileNames {
		t.Run(fmt.Sprintf("ensure %s is in README", fileName), func(t *testing.T) {
			t.Helper()

			fileInReadmeRegexString := fmt.Sprintf("\\|\\s*\\[`%s`\\]", regexp.QuoteMeta(fileName))
			fileInReadmeRegex, err := regexp.Compile(fileInReadmeRegexString)
			if err != nil {
				t.Fatalf("setup: failed to create README regex: %v", err)
			}

			if !fileInReadmeRegex.Match(readmeContents) {
				t.Errorf("%s file was not found in README", fileName)
			}
		})
	}
}