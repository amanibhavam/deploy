package katt

import (
	"encoding/yaml"
	"tool/cli"
)

command: dump: {
	task: print: cli.Print & {
		text: yaml.MarshalStream(projects)
	}
}
