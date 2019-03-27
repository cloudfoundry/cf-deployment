package inline_test

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/sergi/go-diff/diffmatchpatch"
)

func TestInline(t *testing.T) {
	t.Skip("Skipping until generalized")

	wd, err := os.Getwd()
	if err != nil {
		t.Error("get working dir:", err)
	}

	cfDeploymentHome, err := filepath.Abs(filepath.Join(wd, "..", ".."))
	if err != nil {
		t.Error("cf-deployment home setup:", err)
	}

	beforeDir, err := ioutil.TempDir("", "cf-deployment-")
	if err != nil {
		t.Error("setup: temp dir:", err)
	}
	defer os.Remove(beforeDir)

	err = gitSetup(beforeDir)
	if err != nil {
		t.Error("git setup:", err)
	}

	cfDeploymentManifestPath := filepath.Join(cfDeploymentHome, "cf-deployment.yml")

	// before inline
	beforeManifest, err := boshInterpolate(beforeDir, cfDeploymentManifestPath, "operations/use-pxc.yml")
	if err != nil {
		t.Error("before inline manifest interpolation failed:", err)
	}

	// after inline
	afterManifest, err := boshInterpolate(cfDeploymentHome, cfDeploymentManifestPath)
	if err != nil {
		t.Error("after inline manifest interpolation failed:", err)
	}

	// assert that files are the same
	dmp := diffmatchpatch.New()
	beforeDiff, afterDiff, lines := dmp.DiffLinesToChars(beforeManifest, afterManifest)
	diffs := dmp.DiffMain(beforeDiff, afterDiff, true)
	lineDiffs := dmp.DiffCharsToLines(diffs, lines)

	var realDiffs []diffmatchpatch.Diff
	for _, diff := range lineDiffs {
		if diff.Type == diffmatchpatch.DiffEqual {
			continue
		}

		realDiffs = append(realDiffs, diff)
	}

	if len(realDiffs) > 0 {
		t.Errorf("diff mismatch: before..after\n%s", dmp.DiffPrettyText(realDiffs))
	}
}

func gitSetup(tempDir string) error {
	err := runCommandInDirectory(tempDir, "git", "init")
	if err != nil {
		return err
	}

	err = runCommandInDirectory(tempDir, "git", "remote", "add", "origin", "https://github.com/cloudfoundry/cf-deployment")
	if err != nil {
		return err
	}

	err = runCommandInDirectory(tempDir, "git", "fetch", "origin", "master")
	if err != nil {
		return err
	}

	err = runCommandInDirectory(tempDir, "git", "checkout", "FETCH_HEAD", "--", "operations/use-pxc.yml", "cf-deployment.yml")
	if err != nil {
		return err
	}

	return nil
}

func runCommandInDirectory(dir string, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir

	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("%s failed: %s", strings.Join(cmd.Args, " "), string(out))
	}

	return nil
}

func boshInterpolate(dir string, cfDeploymentManifestPath string, opsFiles ...string) (string, error) {
	interpolateArgs := []string{"int", cfDeploymentManifestPath}
	for _, ops := range opsFiles {
		interpolateArgs = append(interpolateArgs, "-o", filepath.Join(dir, ops))
	}

	cmd := exec.Command("bosh", interpolateArgs...)

	out, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("bosh interpolate failed: %s", string(out))
	}

	return string(out), nil
}
