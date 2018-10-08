package helpers

import (
	"fmt"
	"os/exec"
	"path/filepath"
)

type OpsFile struct {
	Name string
	Vars []string
}

func CheckInterpolate(opsFile OpsFile, cfDeploymentHome, operationsSubDir string) error {
	manifest := filepath.Join(cfDeploymentHome, "cf-deployment.yml")
	varsStore := filepath.Join(cfDeploymentHome, "scripts", "fixtures", "unit-test-vars-store.yml")
	execDir := filepath.Join(cfDeploymentHome, operationsSubDir)

	args := []string{}
	args = append(args, "-o", opsFile.Name)
	for _, v := range opsFile.Vars {
		args = append(args, "-v", v)
	}

	return boshInterpolate(execDir, manifest, varsStore, args...)
}

func boshInterpolate(execDir, manifest, varsStore string, args ...string) error {
	interpolateArgs := []string{
		"interpolate", manifest, "--var-errs", "--vars-store", varsStore,
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
