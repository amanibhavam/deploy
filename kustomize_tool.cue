package katt

import (
	"encoding/yaml"
	"tool/cli"
	"tool/file"
)

command: kustomize: {
	for cname, c in deploy for aname, a in c {
		"print-\(cname)-\(aname)": cli.Print & {
			text: "c/\(cname)/\(aname)/kustomization.yaml"
		}
		"kustomization-\(cname)-\(aname)": file.Create & {
			filename: "c/\(cname)/\(aname)/kustomization.yaml"
			contents: yaml.Marshal(a)
		}
	}
}
