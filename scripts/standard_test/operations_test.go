package standard_test

import (
	"testing"

	"tests/helpers"
)

// TODO: ensure every file in "operations" directory has an entry in the tests
// array

func TestOperations(t *testing.T) {
	opsFileTests := []helpers.OpsFileTest{
		{
			Name: "aws.yml",
		},
		{
			Name: "azure.yml",
		},
		{
			Name: "bosh-lite.yml",
		},
		{
			Name: "cf-syslog-skip-cert-verify.yml",
		},
		{
			Name: "configure-confab-timeout.yml", Vars: []string{"confab_timeout=60"},
		},
		{
			Name: "use-offline-windows2016fs.yml",
			Ops:  []string{"windows2016-cell.yml", "use-offline-windows2016fs.yml"},
		},
		{
			Name:      "enable-nfs-ldap.yml",
			Ops:       []string{"enable-nfs-volume-service.yml", "enable-nfs-ldap.yml"},
			VarsFiles: []string{"example-vars-files/vars-enable-nfs-ldap.yml"},
		},
	}

	for _, test := range opsFileTests {
		test := test
		t.Run(test.Name, func(t *testing.T) {
			t.Parallel()
			if err := helpers.CheckInterpolate(test, "operations"); err != nil {
				t.Error("interpolate failed:", err)
			}
		})
	}
}
