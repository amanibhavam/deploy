package katt

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

let apps = {
	imac: {
		"kuma-zone": {
			spec: destination: namespace: "kuma-system"
		}
		cilium: {
			spec: destination: namespace: "kube-system"
			spec: syncPolicy: syncOptions: ["CreateNamespace=false"]
		}
		pihole: {}
		traefik: {}
		"2048": {
			spec: destination: namespace: "katt-2048"
		}
	}
	mbpro: {
		"kuma-zone": {
			spec: destination: namespace: "kuma-system"
		}
		cilium: {
			spec: destination: namespace: "kube-system"
			spec: syncPolicy: syncOptions: ["CreateNamespace=false"]
		}
		pihole: {}
		//traefik: {}
		"2048": {
			spec: destination: namespace: "katt-2048"
		}
	}
	mini: {
		"kuma-global": {
			spec: destination: namespace: "kuma-system"
		}
		cilium: {
			spec: destination: namespace: "kube-system"
			spec: syncPolicy: syncOptions: ["CreateNamespace=false"]
		}
		pihole: {}
	}
	immanent: {
		"kuma-zone": {
			spec: destination: namespace: "kuma-system"
		}
		"argo-workflows": {
			spec: destination: namespace: "argo"
		}
		"traefik": {}
		"traefik-forward-auth": {
			spec: source: repoURL: "https://github.com/letfn/katt-traefik-forward-auth"
			spec: source: path:    "google"

			spec: destination: namespace: "traefik"
		}
		"metacontroller": {}
	}
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
