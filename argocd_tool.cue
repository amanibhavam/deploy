package katt

import (
	"encoding/yaml"
	"tool/file"
)

command: argocd: {
	"create-main.yaml": file.Create & {
		filename: "o/main.yaml"
		contents: yaml.MarshalStream(configs)
	}
}
