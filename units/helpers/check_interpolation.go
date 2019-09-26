package helpers

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type OpsFileTestParams struct {
	Ops           []string      `yaml:",omitempty"`
	Vars          []string      `yaml:",omitempty"`
	VarsFiles     []string      `yaml:",omitempty"`
	PathValidator PathValidator `yaml:",omitempty"`
}

type PathValidator struct {
	Path          string
	ExpectedValue string
}

func BoshInterpolate(execDir, manifestPath, varsStorePath string, args ...string) ([]byte, error) {
	interpolateArgs := []string{
		"interpolate",
		manifestPath,
		"--json",
		"-v", "system_domain=foo.bar.com",
	}

	if varsStorePath != "" {
		interpolateArgs = append(interpolateArgs,
			"--var-errs",
			"--vars-store", varsStorePath,
		)
	}

	interpolateArgs = append(interpolateArgs, args...)

	cmd := exec.Command("bosh", interpolateArgs...)
	cmd.Dir = execDir

	out, err := cmd.CombinedOutput()
	if err != nil {
		return nil, formatBOSHError(out)
	}

	var boshOut boshOut
	err = json.Unmarshal(out, &boshOut)
	if err != nil {
		return nil, err
	}

	if boshOut.Blocks == nil {
		return nil, formatBOSHError(out)
	}

	if len(boshOut.Blocks) != 1 {
		return nil, errors.New("unexpected bosh interpolate json output: length of Blocks is not equal to 1")
	}

	return []byte(boshOut.Blocks[0]), nil
}

func (p PathValidator) HasValidator() bool {
	return p != (PathValidator{})
}

type boshOut struct {
	Blocks []string `json:"Blocks"`
	Lines  []string `json:"Lines"`
}

func checkInterpolate(cfDeploymentHome, operationsSubDir, opsFileName string, opsFileTest OpsFileTestParams) error {
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

	interpolateOutput, err := BoshInterpolate(execDir, manifestPath, tempVarsStorePath, args...)
	if err != nil {
		return err
	}

	if opsFileTest.PathValidator.HasValidator() {
		expected, got := opsFileTest.PathValidator.ExpectedValue, strings.TrimSpace(string(interpolateOutput))
		if expected != got {
			return fmt.Errorf("path value mismatch: expected %s, got %s", expected, got)
		}
	}

	return nil
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

func formatBOSHError(errJSON []byte) error {
	var out boshOut
	err := json.Unmarshal(errJSON, &out)
	if err != nil {
		return fmt.Errorf("bosh error: %s", string(errJSON))
	}

	errLines := new(strings.Builder)
	for _, line := range out.Lines {
		if strings.HasPrefix(line, "Exit code") {
			continue
		}
		fmt.Fprintln(errLines)
		fmt.Fprint(errLines, line)
	}

	return errors.New(errLines.String())
}
