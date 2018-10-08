package helpers

import (
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
)

type OpsFileTest struct {
	Name      string
	Ops       []string
	Vars      []string
	VarsFiles []string
}

func CheckInterpolate(opsFileTest OpsFileTest, operationsSubDir string) error {
	cfDeploymentHome, err := setPath()
	if err != nil {
		return fmt.Errorf("setup: %v", err)
	}

	manifestPath := filepath.Join(cfDeploymentHome, "cf-deployment.yml")
	execDir := filepath.Join(cfDeploymentHome, operationsSubDir)
	tempVarsStorePath, err := getTempVarsStore(cfDeploymentHome)
	if err != nil {
		return err
	}
	defer os.Remove(tempVarsStorePath)

	args := []string{}
	if len(opsFileTest.Ops) == 0 {
		args = append(args, "-o", opsFileTest.Name)
	} else {
		for _, arg := range opsFileTest.Ops {
			args = append(args, "-o", arg)
		}
	}

	for _, v := range opsFileTest.Vars {
		args = append(args, "-v", v)
	}

	for _, l := range opsFileTest.VarsFiles {
		args = append(args, "-l", l)
	}

	return boshInterpolate(execDir, manifestPath, tempVarsStorePath, args...)
}

func boshInterpolate(execDir, manifestPath, varsStorePath string, args ...string) error {
	interpolateArgs := []string{
		"interpolate", manifestPath, "--var-errs", "--vars-store", varsStorePath,
		"-v", "system_domain=foo.bar.com",
	}
	interpolateArgs = append(interpolateArgs, args...)

	cmd := exec.Command("bosh", interpolateArgs...)
	cmd.Dir = execDir

	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("error running bosh interpolate: %s", string(out))
	}

	return nil
}

func getTempVarsStore(cfDeploymentHome string) (string, error) {
	varsStorePath := filepath.Join(cfDeploymentHome, "scripts", "fixtures", "unit-test-vars-store.yml")

	varsStoreFile, err := os.Open(varsStorePath)
	if err != nil {
		return "", fmt.Errorf("error opening varsStorePath: %v", err)
	}
	defer varsStoreFile.Close()

	tempVarsStore, err := ioutil.TempFile("", "vars-store-")
	if err != nil {
		return "", fmt.Errorf("error creating temp vars store: %v", err)
	}
	defer tempVarsStore.Close()

	if _, err := io.Copy(tempVarsStore, varsStoreFile); err != nil {
		return "", fmt.Errorf("error copying tempVarsStore: %v", err)
	}

	return tempVarsStore.Name(), nil
}
