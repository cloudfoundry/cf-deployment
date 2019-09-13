package helpers

import (
	"fmt"
	"os/exec"
	"strings"
)

func RunCommandInDirectory(dir string, name string, args ...string) ([]byte, error) {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir

	out, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("%s failed: %s", strings.Join(cmd.Args, " "), string(out))
	}

	return out, nil
}
