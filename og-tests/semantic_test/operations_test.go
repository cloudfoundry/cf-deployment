package standard_test

import (
	"fmt"
	"og/helpers"
	"path/filepath"
	"testing"

	"gopkg.in/yaml.v2"
)

type network struct {
	Name string `yaml:"name"`
}

type instanceGroup struct {
	Name     string    `yaml:"name"`
	Networks []network `yaml:"networks"`
}

type manifest struct {
	InstanceGroups []instanceGroup `yaml:"instance_groups"`
}

func TestSemantic(t *testing.T) {
	cfDeploymentHome, err := helpers.SetPath()
	if err != nil {
		t.Fatalf("setup: %v", err)
	}

	t.Run("rename-network-and-deployment.yml", func(t *testing.T) {
		operationsSubDirectory := filepath.Join(cfDeploymentHome, "operations")
		manifestPath := filepath.Join(cfDeploymentHome, "cf-deployment.yml")

		expectedNetworkName := "test_network"

		boshInterpolateOutput, err := helpers.BoshInterpolate(operationsSubDirectory,
			manifestPath, "",
			"-o", "rename-network-and-deployment.yml",
			"-v", fmt.Sprintf("network_name=%s", expectedNetworkName),
			"-v", "deployment_name=test_deployment",
		)

		if err != nil {
			t.Errorf("bosh interpolate error: %v", err)
		}

		var manifest manifest
		err = yaml.Unmarshal(boshInterpolateOutput, &manifest)
		if err != nil {
			t.Errorf("failed to unmarshal bosh interpolate output: %v", err)
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
}
