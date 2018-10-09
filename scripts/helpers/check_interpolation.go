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
	Ops       []string
	Vars      []string
	VarsFiles []string
}

func CheckInterpolate(cfDeploymentHome, operationsSubDir, opsFileName string, opsFileTest OpsFileTest) error {
	manifestPath := filepath.Join(cfDeploymentHome, "cf-deployment.yml")
	execDir := filepath.Join(cfDeploymentHome, operationsSubDir)
	tempVarsStorePath, err := createTempVarsStore(cfDeploymentHome)
	if err != nil {
		return err
	}
	defer os.Remove(tempVarsStorePath)

	args := []string{}
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

	return boshInterpolate(execDir, manifestPath, tempVarsStorePath, args...)
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
