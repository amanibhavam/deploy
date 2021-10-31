package katt

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

for gname, clusters in groups for cname in clusters {
	project: #ArgoProject & {
		"\(cname)": {}
	}
	group: #ArgoGroupCluster & {
		"\(gname)": "\(cname)": {}
	}
}
