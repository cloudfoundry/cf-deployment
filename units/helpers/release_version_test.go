package helpers_test

import (
	"fmt"
	"io/ioutil"
	"os"
	"testing"

	"github.com/cf-deployment/units/helpers"

	"github.com/stretchr/testify/assert"
)

func createTempFiles(files []string) (string, error) {
	dir, err := ioutil.TempDir("", "fake-operations-")
	if err != nil {
		return "", err
	}

	for _, file := range files {
		f, err := ioutil.TempFile(dir, "operation-*.yml")
		if err != nil {
			return "", err
		}

		defer f.Close()
		_, err = fmt.Fprint(f, file)
		if err != nil {
			return "", err
		}
	}

	return dir, nil
}

func TestReleaseVersion(t *testing.T) {
	tests := []struct {
		name   string
		input  []string
		output map[helpers.Release][]helpers.Version
	}{
		{
			"simple version",
			[]string{
				`
---
- path: /releases/name=myrelease
  type: replace
  value:
    name: myrelease
    version: 1.0.0
`,
			},
			map[helpers.Release][]helpers.Version{
				"myrelease": {"1.0.0"},
			},
		}, {
			"single file, multiple operations",
			[]string{
				`
---
- path: /releases/name=myrelease
  type: replace
  value:
    name: myrelease
    version: 1.0.0
- path: /releases/name=yourrelease
  type: replace
  value:
    name: yourrelease
    version: 2.0.0
`,
			},
			map[helpers.Release][]helpers.Version{
				"myrelease":   {"1.0.0"},
				"yourrelease": {"2.0.0"},
			},
		}, {
			"multiple versions",
			[]string{
				`
---
- path: /releases/name=myrelease
  type: replace
  value:
    name: myrelease
    version: 1.0.0
`, `
---
- path: /releases/-
  type: replace
  value:
    name: myrelease
    version: 2.0.0
`,
			},
			map[helpers.Release][]helpers.Version{
				"myrelease": {"1.0.0", "2.0.0"},
			},
		}, {
			"non-releases",
			[]string{
				`
---
- type: replace
  path: /releases/name=myrelease/version
  value: 1.0.0
- type: replace
  path: /releases/name=myrelease/sha
  value: 4bcedf13
- type: replace
  path: /notarelease/name=cat/legs
  value: 4
`,
			},
			map[helpers.Release][]helpers.Version{
				"myrelease": {"1.0.0"},
			},
		}, {
			"non opsfile",
			[]string{
				`
---
a: I'm a map
b: And a banana
`,
			},
			map[helpers.Release][]helpers.Version{},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			dir, err := createTempFiles(test.input)
			if err != nil {
				t.Fatal(err)
			}
			defer os.RemoveAll(dir)

			actualReleaseMap, err := helpers.ExtractReleaseVersions("", dir)
			if err != nil {
				t.Fatal(err)
			}

			var expectedReleaseList []helpers.Release
			for release := range test.output {
				expectedReleaseList = append(expectedReleaseList, release)
			}
			var actualReleaseList []helpers.Release
			for release := range actualReleaseMap {
				actualReleaseList = append(actualReleaseList, release)
			}

			assert.ElementsMatch(t, expectedReleaseList, actualReleaseList,
				"expected %q, got %q", expectedReleaseList, actualReleaseList)

			for expectedRelease, expectedVersionList := range test.output {
				if actualVersionMap, ok := actualReleaseMap[expectedRelease]; !ok {
					t.Errorf("missing release: %q", expectedRelease)
				} else {
					var actualVersionList []helpers.Version
					for version := range actualVersionMap.Values() {
						actualVersionList = append(actualVersionList, version)
					}

					assert.ElementsMatch(t, expectedVersionList, actualVersionList,
						"expected %q got %q", expectedVersionList, actualVersionList)
				}
			}
		})
	}
}
