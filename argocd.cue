package katt

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

let apps = {
	imac: {
		"2048": {
			spec: destination: namespace: "katt-2048"
		}
		cilium: {
			spec: destination: namespace: "kube-system"
			spec: syncPolicy: syncOptions: ["CreateNamespace=false"]
		}
		"kuma-zone": {
			spec: destination: namespace: "kuma-system"
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
