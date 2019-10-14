package helpers

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"testing"

	yaml "gopkg.in/yaml.v2"
)

type SuiteTest struct {
	homeDir    string
	testSubDir string

	tests map[string]OpsFileTestParams
}

func NewSuiteTest(cfDeploymentHome, testSubDirectory string) SuiteTest {
	return SuiteTest{
		homeDir:    cfDeploymentHome,
		testSubDir: testSubDirectory,
	}
}

func (suite *SuiteTest) LoadTestOperationsYaml(t *testing.T) {
	content, err := ioutil.ReadFile("operations.yml")
	if err != nil {
		t.Fatalf("Error reading operations file: %s", err)
	}
	opsTests := make(map[string]OpsFileTestParams)
	err = yaml.Unmarshal(content, &opsTests)
	if err != nil {
		t.Fatalf("Error unmarshalling operations.yml: %s", err)
	}
	suite.tests = opsTests
}

func (suite SuiteTest) EnsureTestCoverage(t *testing.T) {
	t.Helper()

	fileNames, err := findFiles(suite.homeDir, suite.testSubDir)
	if err != nil {
		t.Fatalf("setup: find files: %v", err)
	}

	for _, fileName := range fileNames {
		t.Run(fmt.Sprintf("ensure %s has test coverage", fileName), func(t *testing.T) {
			t.Helper()

			if _, hasTest := suite.tests[fileName]; !hasTest {
				t.Errorf("%s has no test", fileName)
			}
		})
	}
}

func (suite SuiteTest) InterpolateTest(t *testing.T) {
	t.Helper()

	for name, params := range suite.tests {
		t.Run(name, suite.checkInterpolate(name, params))
	}
}

func (suite SuiteTest) ReadmeTest(t *testing.T) {
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
		t.Run(fmt.Sprintf("ensure %s is in README", fileName), suite.ensureOpsFileInReadme(fileName, readmeContents))
	}

	filesInReadme, err := findOpsFilesInReadme(readmeContents)
	if err != nil {
		t.Fatalf("setup: parse ops files from README: %v", err)
	}

	for _, fileInReadme := range filesInReadme {
		t.Run(fmt.Sprintf("ensure %s from README exists", fileInReadme), suite.ensureOpsFileFromReadmeExists(fileInReadme))
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

func (SuiteTest) ensureOpsFileInReadme(fileName string, readmeContents []byte) func(t *testing.T) {
	return func(t *testing.T) {
		t.Helper()

		fileInReadmeRegexString := fmt.Sprintf("\\|\\s*\\[`%s`\\]", regexp.QuoteMeta(fileName))
		fileInReadmeRegex, err := regexp.Compile(fileInReadmeRegexString)
		if err != nil {
			t.Fatalf("setup: failed to create README regex: %v", err)
		}

		if !fileInReadmeRegex.Match(readmeContents) {
			t.Errorf("%s file was not found in README", fileName)
		}
	}
}

func (suite SuiteTest) ensureOpsFileFromReadmeExists(fileInReadme string) func(t *testing.T) {
	return func(t *testing.T) {
		t.Helper()

		opsFilePath := filepath.Join(suite.homeDir, suite.testSubDir, fileInReadme)
		if _, err := os.Stat(opsFilePath); os.IsNotExist(err) {
			t.Errorf("%s file from README doesn't exist", fileInReadme)
		}
	}
}

func findOpsFilesInReadme(readmeContents []byte) ([]string, error) {
	rowsInReadmeRegexString := fmt.Sprintf("\\|\\s*\\[`([\\d\\w\\.\\-]*\\.yml)`\\]")
	rowsInReadmeRegex, err := regexp.Compile(rowsInReadmeRegexString)
	if err != nil {
		return nil, err
	}

	rowsInReadme := rowsInReadmeRegex.FindAllStringSubmatch(string(readmeContents), -1)

	var foundOpsFiles []string
	for _, row := range rowsInReadme {
		foundOpsFiles = append(foundOpsFiles, row[1])
	}

	return foundOpsFiles, nil
}
