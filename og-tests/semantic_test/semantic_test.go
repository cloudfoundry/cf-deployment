package standard_test

import (
	"fmt"
	"og/helpers"
	"path/filepath"
	"testing"

	"gopkg.in/yaml.v2"
)

type instanceGroup struct {
	Name     string
	Networks []struct {
		Name string
	}
	Jobs []struct {
		Properties struct {
			Doppler struct {
				Port *int
			}
		}
	}
}

type manifest struct {
	InstanceGroups []instanceGroup `yaml:"instance_groups"`
}

func TestSemantic(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	operationsSubDirectory := filepath.Join(cfDeploymentHome, "operations")
	manifestPath := filepath.Join(cfDeploymentHome, "cf-deployment.yml")

	t.Run("rename-network-and-deployment.yml", func(t *testing.T) {
		expectedNetworkName := "test_network"

		manifest, err := boshInterpolateAndUnmarshal(
			operationsSubDirectory,
			manifestPath,
			"-o", "rename-network-and-deployment.yml",
			"-v", fmt.Sprintf("network_name=%s", expectedNetworkName),
			"-v", "deployment_name=test_deployment",
		)

		if err != nil {
			t.Errorf("failed to get unmarshalled manifest: %v", err)
		}

		for _, ig := range manifest.InstanceGroups {
			if len(ig.Networks) != 1 {
				t.Errorf("instance group '%s' should only have 1 network", ig.Name)
			}

			networkName := ig.Networks[0].Name
			if networkName != expectedNetworkName {
				t.Errorf("network name '%s' on instance '%s' does not match expected network name '%s'", networkName, ig.Name, expectedNetworkName)
			}
		}
	})

	t.Run("aws.yml", func(t *testing.T) {
		expectedAWSDopplerPort := 4443

		manifest, err := boshInterpolateAndUnmarshal(
			operationsSubDirectory,
			manifestPath,
			"-o", "aws.yml",
		)

		if err != nil {
			t.Errorf("failed to get unmarshalled manifest: %v", err)
		}

		for _, ig := range manifest.InstanceGroups {
			for _, j := range ig.Jobs {
				portNumber := j.Properties.Doppler.Port

				if portNumber != nil && *portNumber != expectedAWSDopplerPort {
					t.Errorf("port number '%v' on instance '%s' does not match expected port number '%v'", portNumber, ig.Name, expectedAWSDopplerPort)
				}

			}
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
