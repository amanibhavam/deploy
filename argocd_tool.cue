package katt

import (
	"encoding/yaml"
	"tool/file"
)

command: argocd: {
	"projects": file.Create & {
		filename: "a/projects.yaml"
		contents: yaml.MarshalStream(projects)
	}
	for cname, apps in clusters {
		"cluster-\(cname)": file.Create & {
			filename: "a/cluster-\(cname).yaml"
			contents: yaml.MarshalStream(apps)
		}
	}
}
