package boot

import (
	"encoding/yaml"
	"tool/file"
)

_projects: [ for pname, p in project {p}]

_clusters: {
	for cname, apps in application {
		"\(cname)": [ for a in apps {a}]
	}
}

command: argocd: {
	"projects": file.Create & {
		filename: "a/projects.yaml"
		contents: yaml.MarshalStream(_projects)
	}
	for cname, apps in _clusters {
		"cluster-\(cname)": file.Create & {
			filename: "a/cluster-\(cname).yaml"
			contents: yaml.MarshalStream(apps)
		}
	}
}
