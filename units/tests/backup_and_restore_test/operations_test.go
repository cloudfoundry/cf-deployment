package backupandrestore_test

import (
	"fmt"
	"path/filepath"
	"testing"

	"gopkg.in/yaml.v2"

	"github.com/cf-deployment/units/helpers"
)

type manifest struct {
	InstanceGroups []struct {
		Name string
		Jobs []struct {
			Name       string
			Properties struct {
				SelectDirectoriesToBackup []string `yaml:"select_directories_to_backup"`
			}
		}
	} `yaml:"instance_groups"`
}

const testDirectory = "operations/backup-and-restore"

var backupAndRestoreTests = map[string]helpers.OpsFileTestParams{
	//internal
	"enable-backup-restore.yml": {
		Ops: []string{"enable-backup-restore.yml"},
	},
	"skip-backup-restore-droplets.yml": {
		Ops: []string{"enable-backup-restore.yml", "skip-backup-restore-droplets.yml"},
	},
	"skip-backup-restore-droplets-and-packages.yml": {
		Ops: []string{"enable-backup-restore.yml", "skip-backup-restore-droplets-and-packages.yml"},
	},

	//azure
	"enable-backup-restore-azure.yml": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-azure-storage-blobstore.yml", "enable-backup-restore-azure.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-azure-storage-blobstore.yml"},
	},
	"enable-backup-restore-azure.yml with skip droplets": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-azure-storage-blobstore.yml", "enable-backup-restore-azure.yml", "skip-backup-restore-droplets.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-azure-storage-blobstore.yml"},
	},
	"enable-backup-restore-azure.yml with skip droplets and packages": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-azure-storage-blobstore.yml", "enable-backup-restore-azure.yml", "skip-backup-restore-droplets-and-packages.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-azure-storage-blobstore.yml"},
	},

	//azure-clone
	"enable-restore-azure-clone.yml": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-azure-storage-blobstore.yml", "enable-restore-azure-clone.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-azure-storage-blobstore.yml", "example-vars-files/vars-enable-restore-azure-clone.yml"},
	},
	"enable-restore-azure-clone.yml with skip droplets": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-azure-storage-blobstore.yml", "enable-restore-azure-clone.yml", "skip-backup-restore-droplets.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-azure-storage-blobstore.yml", "example-vars-files/vars-enable-restore-azure-clone.yml"},
	},
	"enable-restore-azure-clone.yml with skip droplets and packages": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-azure-storage-blobstore.yml", "enable-restore-azure-clone.yml", "skip-backup-restore-droplets-and-packages.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-azure-storage-blobstore.yml", "example-vars-files/vars-enable-restore-azure-clone.yml"},
	},

	//gcs
	"enable-backup-restore-gcs.yml": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-gcs-blobstore-service-account.yml", "enable-backup-restore-gcs.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-gcs-blobstore-service-account.yml", "example-vars-files/vars-enable-backup-restore-gcs.yml"},
	},
	"enable-backup-restore-gcs.yml with skip droplets": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-gcs-blobstore-service-account.yml", "enable-backup-restore-gcs.yml", "skip-backup-restore-droplets.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-gcs-blobstore-service-account.yml", "example-vars-files/vars-enable-backup-restore-gcs.yml"},
	},
	"enable-backup-restore-gcs.yml with skip droplets and packages": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-gcs-blobstore-service-account.yml", "enable-backup-restore-gcs.yml", "skip-backup-restore-droplets-and-packages.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-gcs-blobstore-service-account.yml", "example-vars-files/vars-enable-backup-restore-gcs.yml"},
	},

	//s3-unversioned
	"enable-backup-restore-s3-unversioned.yml": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-s3-blobstore.yml", "enable-backup-restore-s3-unversioned.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-s3-blobstore.yml", "example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"},
	},
	"enable-backup-restore-s3-unversioned.yml with skip droplets": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-s3-blobstore.yml", "enable-backup-restore-s3-unversioned.yml", "skip-backup-restore-droplets.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-s3-blobstore.yml", "example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"},
	},
	"enable-backup-restore-s3-unversioned.yml with skip droplets and packages": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-s3-blobstore.yml", "enable-backup-restore-s3-unversioned.yml", "skip-backup-restore-droplets-and-packages.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-s3-blobstore.yml", "example-vars-files/vars-enable-backup-restore-s3-unversioned.yml"},
	},

	//s3-versioned
	"enable-backup-restore-s3-versioned.yml": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-s3-blobstore.yml", "enable-backup-restore-s3-versioned.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-s3-blobstore.yml"},
	},
	"enable-backup-restore-s3-versioned.yml with skip droplets": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-s3-blobstore.yml", "enable-backup-restore-s3-versioned.yml", "skip-backup-restore-droplets.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-s3-blobstore.yml"},
	},
	"enable-backup-restore-s3-versioned.yml with skip droplets and packages": {
		Ops:       []string{"enable-backup-restore.yml", "../use-external-blobstore.yml", "../use-s3-blobstore.yml", "enable-backup-restore-s3-versioned.yml", "skip-backup-restore-droplets-and-packages.yml"},
		VarsFiles: []string{"../example-vars-files/vars-use-s3-blobstore.yml"},
	},

	//nfs-broker
	"enable-restore-nfs-broker.yml": {
		Ops: []string{"enable-backup-restore.yml", "../enable-nfs-volume-service.yml", "skip-backup-restore-droplets-and-packages.yml", "enable-restore-nfs-broker.yml"},
	},
	"enable-restore-smb-broker.yml": {
		Ops: []string{"enable-backup-restore.yml", "../enable-smb-volume-service.yml", "skip-backup-restore-droplets-and-packages.yml", "enable-restore-smb-broker.yml"},
	},
}

func TestBackupAndRestore(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	suite := helpers.NewSuiteTest(cfDeploymentHome, testDirectory, backupAndRestoreTests)
	suite.EnsureTestCoverage(t)
	suite.ReadmeTest(t)
	suite.InterpolateTest(t)

	operationsSubDirectory := filepath.Join(cfDeploymentHome, "operations")
	manifestPath := filepath.Join(cfDeploymentHome, "cf-deployment.yml")

	t.Run("skip droplets", func(t *testing.T) {
		manifest, err := boshInterpolateAndUnmarshal(
			operationsSubDirectory,
			manifestPath,
			"-o", "backup-and-restore/enable-backup-restore.yml", "-o", "backup-and-restore/skip-backup-restore-droplets.yml",
		)

		if err != nil {
			t.Errorf("failed to bosh interpolate: %v", err)
		}

		dirs := findDirectoriesToBackup(manifest)
		if !(len(dirs) == 2 && dirs[0] == "buildpacks" && dirs[1] == "packages") {
			t.Error("Ops file skip-backup-restore-droplets.yml is failing to remove droplets directories from select_directories_to_backup")
		}
	})

	t.Run("skip droplets and packages", func(t *testing.T) {
		manifest, err := boshInterpolateAndUnmarshal(
			operationsSubDirectory,
			manifestPath,
			"-o", "backup-and-restore/enable-backup-restore.yml", "-o", "backup-and-restore/skip-backup-restore-droplets-and-packages.yml",
		)

		if err != nil {
			t.Errorf("failed to bosh interpolate: %v", err)
		}

		dirs := findDirectoriesToBackup(manifest)
		if !(len(dirs) == 1 && dirs[0] == "buildpacks") {
			t.Error("Ops file skip-backup-restore-droplets-and-packages.yml is failing to remove droplets and packages directories from select_directories_to_backup")
		}
	})
}

func boshInterpolateAndUnmarshal(opsSubDir, manifestPath string, args ...string) (manifest, error) {
	boshInterpolateOutput, err := helpers.BoshInterpolate(opsSubDir, manifestPath, "", args...)

	if err != nil {
		return manifest{}, fmt.Errorf("bosh interpolate error: %v", err)
	}

	var m manifest
	err = yaml.Unmarshal(boshInterpolateOutput, &m)
	if err != nil {
		return manifest{}, fmt.Errorf("failed to unmarshal bosh interpolate output: %v", err)
	}

	return m, nil
}

func findDirectoriesToBackup(manifest manifest) []string {
	for _, instanceGroup := range manifest.InstanceGroups {
		if instanceGroup.Name == "singleton-blobstore" {
			for _, job := range instanceGroup.Jobs {
				if job.Name == "blobstore" {
					return job.Properties.SelectDirectoriesToBackup
				}
			}
		}
	}
	return []string{}
}
