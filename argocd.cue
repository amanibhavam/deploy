package katt

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

let apps = {
	imac: {
		"2048": {
			destination: namespace: "katt-2048"
		}
		cilium: {
			destination: namespace: "kube-system"
			syncOptions: [{CreateNamespace: false}]
		}
		"kuma-zone": {
			destination: namespace: "kuma-system"
		}
		pihole: {}
		traefik: {}
	}
	mini: {}
	mbpro: {}
	immanent: {}
}

for gname, clusters in groups for cname in clusters {
	project: #ArgoProject & {
		"\(cname)": {}
	}

	group: #ArgoGroupCluster & {
		"\(gname)": "\(cname)": {}
	}

	for aname, app in apps[cname] {
		application: #ArgoApplication & {
			"\(cname)": "\(aname)": app
		}
	}
}
