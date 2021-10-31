package katt

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

let clusterNames = [ for _, g in groups for c in g {c}]

for c in clusterNames {
	project: #ArgoProject & {
		"\(c)": {}
	}
}

for gname, g in groups for c in g {
	group: #ArgoGroupCluster & {
		"\(gname)": "\(c)": {}
	}
}
