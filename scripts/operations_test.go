package tests

import (
	"testing"

	"tests/helpers"
)

func TestOperations(t *testing.T) {
	tests := []helpers.OpsFile{
		{Name: "aws.yml"},
		{Name: "azure.yml"},
		{Name: "bosh-lite.yml"},
		{Name: "cf-syslog-skip-cert-verify.yml"},
		{Name: "configure-confab-timeout.yml", Vars: []string{"confab_timeout=60"}},
	}

	for _, test := range tests {
		t.Run(test.Name, func(t *testing.T) {
			t.Parallel()
			if err := helpers.CheckInterpolate(test, cfDeploymentHome, "operations"); err != nil {
				t.Fatal("interpolate failed:", err)
			}
		})
	}
}
