package legacy_test

import (
	"testing"

	"github.com/cf-deployment/units/helpers"
)

const testDirectory = "operations/legacy"

var legacyTests = map[string]helpers.OpsFileTestParams{
	"keep-haproxy-ssl-pem.yml": {
		Ops:  []string{"../use-haproxy.yml", "keep-haproxy-ssl-pem.yml"},
		Vars: []string{"haproxy_ssl_pem=i-am-a-pem", "haproxy_private_ip=1.2.3.4"},
	},
	"keep-original-blobstore-directory-keys.yml": {
		VarsFiles: []string{"example-vars-files/vars-keep-original-blobstore-directory-keys.yml"},
	},
	"keep-original-internal-usernames.yml": {
		VarsFiles: []string{"example-vars-files/vars-keep-original-internal-usernames.yml"},
	},
	"keep-original-postgres-configuration.yml": {
		Ops:       []string{"../use-postgres.yml", "keep-original-postgres-configuration.yml"},
		VarsFiles: []string{"example-vars-files/vars-keep-original-postgres-configuration.yml"},
	},
	"keep-original-routing-postgres-configuration.yml": {
		Ops:  []string{"../use-postgres.yml", "keep-original-routing-postgres-configuration.yml"},
		Vars: []string{"routing_api_database_name=routing-api-db", "routing_api_database_username=routing-api-user"},
	},
	"keep-static-ips.yml": {
		VarsFiles: []string{"example-vars-files/vars-keep-static-ips.yml"},
	},
	"old-droplet-mitigation.yml": {},
}

func TestLegacy(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, legacyTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
