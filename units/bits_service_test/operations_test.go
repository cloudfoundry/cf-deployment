package bitsservice_test

import (
	"testing"

	"github.com/cf-deployment/units/helpers"
)

const testDirectory = "operations/bits-service"

var bitsServiceTests = map[string]helpers.OpsFileTestParams{
	"configure-bits-service-alicloud-oss.yml": {
		Ops:       []string{"../use-external-blobstore.yml", "../use-alicloud-oss-blobstore.yml", "use-bits-service.yml", "configure-bits-service-alicloud-oss.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-alicloud-oss-blobstore.yml"},
	},
	"configure-bits-service-azure-storage.yml": {
		Ops:       []string{"../use-external-blobstore.yml", "../use-azure-storage-blobstore.yml", "use-bits-service.yml", "configure-bits-service-azure-storage.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-azure-storage-blobstore.yml"},
	},
	"configure-bits-service-gcs-access-key.yml": {
		Ops:       []string{"../use-external-blobstore.yml", "../use-gcs-blobstore-access-key.yml", "use-bits-service.yml", "configure-bits-service-gcs-access-key.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-gcs-blobstore-access-key.yml"},
	},
	"configure-bits-service-gcs-service-account.yml": {
		Ops:       []string{"../use-external-blobstore.yml", "../use-gcs-blobstore-service-account.yml", "use-bits-service.yml", "configure-bits-service-gcs-service-account.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-gcs-blobstore-service-account.yml"},
	},
	"configure-bits-service-s3.yml": {
		Ops:       []string{"../use-external-blobstore.yml", "../use-s3-blobstore.yml", "use-bits-service.yml", "configure-bits-service-s3.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-s3-blobstore.yml"},
	},
	"configure-bits-service-swift.yml": {
		Ops:       []string{"../use-external-blobstore.yml", "../use-swift-blobstore.yml", "use-bits-service.yml", "configure-bits-service-swift.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-swift-blobstore.yml"},
	},
	"use-bits-service.yml": {},
}

func TestBitSservice(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, bitsServiceTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)
}
