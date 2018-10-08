package tests

import (
	"log"
	"os"
	"path/filepath"
	"testing"
)

var cfDeploymentHome string

func TestMain(m *testing.M) {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatal("setup:", err)
	}
	cfDeploymentHome, err = filepath.Abs(filepath.Join(wd, ".."))
	if err != nil {
		log.Fatal("setup:", err)
	}
	log.Println(cfDeploymentHome)

	os.Exit(m.Run())
}
