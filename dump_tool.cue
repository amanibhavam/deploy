package katt

import (
	"encoding/yaml"
	"tool/file"
)

command: dump: {
	"create-main.yaml": file.Create & {
		filename: "o/main.yaml"
		contents: yaml.MarshalStream(configs)
	}
}
