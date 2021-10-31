package katt

let clusterNames = [ "mini", "imac", "mbpro", "immanent"]

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

for c in clusterNames {
	cluster: "\(c)": {}
}

for gname, g in groups for c in g {
	group: "\(gname)": "\(c)": {}
}
