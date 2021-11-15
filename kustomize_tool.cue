package katt

import (
	"encoding/yaml"
	"tool/cli"
	"tool/file"
	"strings"
)

command: kustomize: {
	for cname, c in deploy for aname, a in c {
		"print-\(cname)-\(aname)": cli.Print & {
			text: strings.ToLower("c/\(cname)/\(aname)/kustomization.yaml")
		}
		"kustomization-\(cname)-\(aname)": file.Create & {
			filename: strings.ToLower("c/\(cname)/\(aname)/kustomization.yaml")
			contents: yaml.Marshal(a)
		}
		for rname, r in a._resources {
			"resource-\(cname)-\(aname)-\(r.kind)-\(r.metadata.name)": file.Create & {
				filename: strings.ToLower("c/\(cname)/\(aname)/resource-\(r.kind)-\(r.metadata.name).yaml")
				contents: yaml.Marshal(r)
			}
		}
		for pname, p in a._patches {
			"patch-\(cname)-\(aname)-\(pname)": file.Create & {
				filename: strings.ToLower("c/\(cname)/\(aname)/patch-\(pname).yaml")
				contents: yaml.Marshal(p.ops)
			}
		}
	}
}
