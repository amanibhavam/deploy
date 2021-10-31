package katt

let clusterNames = [ "mini", "imac", "mbpro", "immanent"]

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

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
