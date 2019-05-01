package standard_test

import (
	"testing"

	"github.com/cf-deployment/units/helpers"
)

const testDirectory = "operations"

var standardTests = map[string]helpers.OpsFileTestParams{
	"aws.yml":                        {},
	"azure.yml":                      {},
	"bosh-lite.yml":                  {},
	"cf-syslog-skip-cert-verify.yml": {},
	"configure-default-router-group.yml": {
		Vars: []string{"default_router_group_reservable_ports=1234-2024"},
	},
	"disable-router-tls-termination.yml": {},
	"enable-cc-rate-limiting.yml": {
		Vars: []string{"cc_rate_limiter_general_limit=blah", "cc_rate_limiter_unauthenticated_limit=something"},
	},
	"enable-nfs-ldap.yml": {
		Ops:       []string{"enable-nfs-volume-service.yml", "enable-nfs-ldap.yml"},
		VarsFiles: []string{"example-vars-files/vars-enable-nfs-ldap.yml"},
	},
	"enable-nfs-volume-service.yml":           {},
	"enable-privileged-container-support.yml": {},
	"enable-routing-integrity.yml":            {},
	"enable-service-discovery.yml":            {},
	"enable-smb-volume-service.yml":           {},
	"migrate-cf-mysql-to-pxc.yml":             {},
	"openstack.yml":                           {},
	"override-app-domains.yml": {
		VarsFiles: []string{"example-vars-files/vars-override-app-domains.yml"},
	},
	"rename-network-and-deployment.yml": {
		Vars: []string{"deployment_name=renamed_deployment", "network_name=renamed_network"},
	},
	"scale-database-cluster.yml": {},
	"scale-to-one-az.yml":        {},
	"set-bbs-active-key.yml": {
		Vars: []string{"diego_bbs_active_key_label=my_key_name"},
	},
	"set-router-static-ips.yml": {
		Vars: []string{"router_static_ips=[10.0.16.4,10.0.47.5]"},
	},
	"stop-skipping-tls-validation.yml": {},
	"use-alicloud-oss-blobstore.yml": {
		Ops:       []string{"use-external-blobstore.yml", "use-alicloud-oss-blobstore.yml"},
		VarsFiles: []string{"example-vars-files/vars-use-alicloud-oss-blobstore.yml"},
	},
	"use-azure-storage-blobstore.yml": {
		Ops:       []string{"use-external-blobstore.yml", "use-azure-storage-blobstore.yml"},
		VarsFiles: []string{"example-vars-files/vars-use-azure-storage-blobstore.yml"},
	},
	"use-blobstore-cdn.yml": {
		VarsFiles: []string{"example-vars-files/vars-use-blobstore-cdn.yml"},
	},
	"use-compiled-releases.yml": {},
	"use-external-blobstore.yml": {
		VarsFiles: []string{"example-vars-files/vars-use-external-blobstore.yml"},
	},
	"use-external-dbs.yml": {
		VarsFiles: []string{"example-vars-files/vars-use-external-dbs.yml"},
	},
	"use-gcs-blobstore-access-key.yml": {
		Ops:       []string{"use-external-blobstore.yml", "use-gcs-blobstore-access-key.yml"},
		Vars:      []string{"blobstore_access_key_id=TEST_ACCESS_KEY", "blobstore_secret_access_key=TEST_SECRET_ACCESS_KEY"},
		VarsFiles: []string{"example-vars-files/vars-use-gcs-blobstore-access-key.yml"},
	},
	"use-gcs-blobstore-service-account.yml": {
		Ops:       []string{"use-external-blobstore.yml", "use-gcs-blobstore-service-account.yml"},
		VarsFiles: []string{"example-vars-files/vars-use-gcs-blobstore-service-account.yml"},
	},
	"use-haproxy-public-network.yml": {
		Ops:  []string{"use-haproxy.yml", "use-haproxy-public-network.yml"},
		Vars: []string{"haproxy_public_network_name=public", "haproxy_public_ip=6.7.8.9"},
	},
	"use-haproxy.yml": {
		Vars: []string{"haproxy_private_ip=10.0.10.10"},
	},
	"use-internal-lookup-for-route-services.yml": {},
	"use-latest-stemcell.yml": {
		PathValidator: helpers.PathValidator{
			Path: "/stemcells/alias=default/version", ExpectedValue: "latest",
		},
	},
	"use-latest-windows2012R2-stemcell.yml": {
		Ops: []string{"windows2012R2-cell.yml", "use-latest-windows2012R2-stemcell.yml"},
		PathValidator: helpers.PathValidator{
			Path: "/stemcells/alias=windows2012R2/version", ExpectedValue: "latest",
		},
	},
	"use-latest-windows2016-stemcell.yml": {
		Ops: []string{"windows2016-cell.yml", "use-latest-windows2016-stemcell.yml"},
		PathValidator: helpers.PathValidator{
			Path: "/stemcells/alias=windows2016/version", ExpectedValue: "latest",
		},
	},
	"use-latest-windows1803-stemcell.yml": {
		Ops: []string{"windows1803-cell.yml", "use-latest-windows1803-stemcell.yml"},
		PathValidator: helpers.PathValidator{
			Path: "/stemcells/alias=windows1803/version", ExpectedValue: "latest",
		},
	},
	"use-latest-windows2019-stemcell.yml": {
		Ops: []string{"windows2019-cell.yml", "use-latest-windows2019-stemcell.yml"},
		PathValidator: helpers.PathValidator{
			Path: "/stemcells/alias=windows2019/version", ExpectedValue: "latest",
		},
	},
	"use-offline-windows2016fs.yml": {
		Ops: []string{"windows2016-cell.yml", "use-offline-windows2016fs.yml"},
	},
	"use-online-windows2019fs.yml": {
		Ops: []string{"windows2019-cell.yml", "use-online-windows2019fs.yml"},
	},
	"use-operator-provided-router-tls-certificates.yml": {
		VarsFiles: []string{"example-vars-files/vars-use-operator-provided-router-tls-certificates.yml"},
	},
	"use-postgres.yml": {},
	"use-pxc-for-nfs-volume-service.yml": {
		Ops: []string{"enable-nfs-volume-service.yml", "use-pxc.yml", "use-pxc-for-nfs-volume-service.yml"},
	},
	"use-pxc.yml": {},
	"use-s3-blobstore.yml": {
		Ops:       []string{"use-external-blobstore.yml", "use-s3-blobstore.yml"},
		VarsFiles: []string{"example-vars-files/vars-use-s3-blobstore.yml"},
	},
	"use-swift-blobstore.yml": {
		Ops:       []string{"use-external-blobstore.yml", "use-swift-blobstore.yml"},
		VarsFiles: []string{"example-vars-files/vars-use-swift-blobstore.yml"},
	},
	"use-trusted-ca-cert-for-apps.yml": {
		VarsFiles: []string{"example-vars-files/vars-use-trusted-ca-cert-for-apps.yml"},
	},
	"windows2012R2-cell.yml windows2016-cell.yml": {
		Ops: []string{"windows2012R2-cell.yml", "windows2016-cell.yml"},
	},
	"windows2012R2-cell.yml": {},
	"windows2016-cell.yml":   {},
	"windows2019-cell.yml":   {},
	"windows1803-cell.yml":   {},
}

func TestStandard(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, standardTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
