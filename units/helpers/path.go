package helpers

import (
	"os"
	"path/filepath"
)

func SetPath() (string, error) {
	wd, err := os.Getwd()
	if err != nil {
		return "", err
	}

	return filepath.Abs(filepath.Join(wd, "..", "..", ".."))
}

func findFiles(cfDeploymentHome, operationsSubDir string) ([]string, error) {
	searchPath := filepath.Join(cfDeploymentHome, operationsSubDir, "*.yml")
	filePaths, err := filepath.Glob(searchPath)
	if err != nil {
		return nil, err
	}

	var fileNames []string
	for _, filePath := range filePaths {
		fileNames = append(fileNames, filepath.Base(filePath))
	}

	return fileNames, nil
}
