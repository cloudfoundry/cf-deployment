package helpers

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	yaml "gopkg.in/yaml.v2"
)

type Release string
type Version string

type VersionSet struct {
	m map[Version]struct{}
}

func newVersionSet(version Version) VersionSet {
	return VersionSet{m: map[Version]struct{}{version: struct{}{}}}
}

func (s *VersionSet) add(version Version) {
	s.m[version] = struct{}{}
}

func (s VersionSet) Values() map[Version]struct{} {
	return s.m
}

func (s VersionSet) String() string {
	var versions []Version
	for version := range s.m {
		versions = append(versions, version)
	}

	return fmt.Sprintf("%q", versions)
}

type Filename string

type opsfile struct {
	ops []operation
}

func (o *opsfile) UnmarshalYAML(unmarshal func(interface{}) error) error {
	if ok, err := isOpsFile(unmarshal); err != nil {
		return err
	} else if !ok {
		return nil
	}

	type alias []operation
	var a alias
	if err := unmarshal(&a); err != nil {
		return err
	}

	o.ops = a
	return nil
}

func isOpsFile(unmarshal func(interface{}) error) (bool, error) {
	var a interface{}
	if err := unmarshal(&a); err != nil {
		return false, err
	}

	_, ok := a.([]interface{})
	return ok, nil
}

type operation struct {
	Path  string
	Type  string
	Value value
}

func (o *operation) UnmarshalYAML(unmarshal func(interface{}) error) error {
	type alias operation

	var a alias
	if err := unmarshal(&a); err != nil {
		return err
	}

	o.Path = a.Path
	o.Type = a.Type
	o.Value = a.Value

	if o.Value.Name != "" {
		return nil
	}

	name := regexp.MustCompile(`/name=(.*)/version`)
	matches := name.FindStringSubmatch(o.Path)

	if len(matches) < 2 {
		o = nil
		return nil
	}
	o.Value.Name = Release(matches[1])

	return nil
}

type value struct {
	Name    Release
	Version Version
}

func (v *value) UnmarshalYAML(unmarshal func(interface{}) error) error {
	var a interface{}
	if err := unmarshal(&a); err != nil {
		return err
	}

	switch val := a.(type) {
	case string:
		v.Version = Version(val)
	case map[interface{}]interface{}:
		type alias value
		var a alias
		if err := unmarshal(&a); err != nil {
			return fmt.Errorf("invalid type %T: %v", a, err)
		}

		*v = value(a)
	}

	return nil
}

func ExtractReleaseVersions(manifest string, operationRoot string) (map[Release]VersionSet, error) {
	releaseVersionMap := make(map[Release]VersionSet)

	err := filepath.Walk(operationRoot, operationsWalk(func(val value) {
		versionSet, ok := releaseVersionMap[val.Name]
		if !ok {
			releaseVersionMap[val.Name] = newVersionSet(val.Version)
			return
		}

		versionSet.add(val.Version)
		releaseVersionMap[val.Name] = versionSet
	}))
	if err != nil {
		return nil, err
	}

	return releaseVersionMap, nil
}

func operationsWalk(assignFn func(value)) filepath.WalkFunc {
	return func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		if filepath.Ext(info.Name()) != ".yml" {
			return nil
		}

		handler, err := os.Open(path)
		if err != nil {
			return err
		}

		vals, err := readOpsFile(handler)
		if err != nil {
			return fmt.Errorf("reading file %q: %v", info.Name(), err)
		}
		for _, val := range vals {
			assignFn(val)
		}

		return nil
	}
}

func readOpsFile(r io.Reader) ([]value, error) {
	var opsfile opsfile

	err := yaml.NewDecoder(r).Decode(&opsfile)
	if err == io.EOF {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("decoding stream: %v", err)
	}
	var vals []value

	for _, op := range opsfile.ops {
		if op.Value.Name == "" {
			continue
		}
		if !strings.HasPrefix(op.Path, "/releases/") {
			continue
		}

		vals = append(vals, op.Value)
	}

	return vals, nil
}
