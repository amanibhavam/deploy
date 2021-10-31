package katt

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

for gname, g in groups for c in g {
	project: #ArgoProject & {
		"\(c)": {}
	}
	group: #ArgoGroupCluster & {
		"\(gname)": "\(c)": {}
	}
}
