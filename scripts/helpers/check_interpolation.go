package helpers

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type PathValidator struct {
	Path          string
	ExpectedValue string
}

func (p PathValidator) HasValidator() bool {
	return p != (PathValidator{})
}

type OpsFileTestParams struct {
	Ops           []string
	Vars          []string
	VarsFiles     []string
	PathValidator PathValidator
}

type boshOut struct {
	Blocks []string `json:"Blocks"`
}

func CheckInterpolate(cfDeploymentHome, operationsSubDir, opsFileName string, opsFileTest OpsFileTestParams) error {
	manifestPath := filepath.Join(cfDeploymentHome, "cf-deployment.yml")
	execDir := filepath.Join(cfDeploymentHome, operationsSubDir)
	tempVarsStorePath, err := createTempVarsStore(cfDeploymentHome)
	if err != nil {
		return err
	}
	defer os.Remove(tempVarsStorePath)

	var args []string
	if len(opsFileTest.Ops) == 0 {
		args = append(args, "-o", opsFileName)
	} else {
		for _, o := range opsFileTest.Ops {
			args = append(args, "-o", o)
		}
	}

	for _, v := range opsFileTest.Vars {
		args = append(args, "-v", v)
	}

	for _, l := range opsFileTest.VarsFiles {
		args = append(args, "-l", l)
	}

	if opsFileTest.PathValidator.HasValidator() {
		args = append(args, "--path", opsFileTest.PathValidator.Path)
	}

	outJSON, err := boshInterpolate(execDir, manifestPath, tempVarsStorePath, args...)
	if err != nil {
		return err
	}

	if opsFileTest.PathValidator.HasValidator() {
		var out boshOut
		err := json.Unmarshal(outJSON, &out)
		if err != nil {
			return err
		}

		// "latest"
		expected, got := opsFileTest.PathValidator.ExpectedValue, strings.TrimSpace(out.Blocks[0])
		if expected != got {
			return fmt.Errorf("path value mismatch: expected %s, got %s", expected, got)
		}
	}

	return nil
}

func FindFiles(cfDeploymentHome, operationsSubDir string) ([]string, error) {
	searchPath := filepath.Join(cfDeploymentHome, operationsSubDir, "*.yml")
	filePaths, err := filepath.Glob(searchPath)
	if err != nil {
		return nil, err
	}

	var fileNames []string
	for _, filePath := range filePaths {
		fileNames = append(fileNames, filepath.Base(filePath))
	}

	return fileNames, nil
}

func createTempVarsStore(cfDeploymentHome string) (string, error) {
	varsStorePath := filepath.Join(cfDeploymentHome, "scripts", "fixtures", "unit-test-vars-store.yml")

	varsStoreFile, err := os.Open(varsStorePath)
	if err != nil {
		return "", fmt.Errorf("error opening varsStorePath: %v", err)
	}
	defer varsStoreFile.Close()

	tempVarsStoreFile, err := ioutil.TempFile("", "vars-store-")
	if err != nil {
		return "", fmt.Errorf("error creating temp vars store: %v", err)
	}
	defer tempVarsStoreFile.Close()

	if _, err := io.Copy(tempVarsStoreFile, varsStoreFile); err != nil {
		return "", fmt.Errorf("error copying tempVarsStore: %v", err)
	}

	return tempVarsStoreFile.Name(), nil
}

func boshInterpolate(execDir, manifestPath, varsStorePath string, args ...string) ([]byte, error) {
	interpolateArgs := []string{
		"interpolate", manifestPath, "--json",
		"--var-errs", "--vars-store", varsStorePath,
		"-v", "system_domain=foo.bar.com",
	}
	interpolateArgs = append(interpolateArgs, args...)

	cmd := exec.Command("bosh", interpolateArgs...)
	cmd.Dir = execDir

	out, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("error running bosh interpolate: %s", string(out))
	}

	return out, nil
}
