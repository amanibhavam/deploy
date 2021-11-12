package katt

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
}

let apps = {
	cilium: {
		spec: destination: namespace: "kube-system"
		spec: syncPolicy: syncOptions: ["CreateNamespace=false"]
	}
	"kuma-global": {
		spec: destination: namespace: "kuma-system"
	}
	"kuma-zone": {
		spec: destination: namespace: "kuma-system"
	}
	"kong": {}
	"argo-workflows": {
		spec: destination: namespace: "argo"
	}
	"traefik-forward-auth": {
		spec: source: repoURL: "https://github.com/letfn/katt-traefik-forward-auth"
		spec: source: path:    "google"

		spec: destination: namespace: "traefik"
	}
	"docker-registry": {}
}

let clusters = {
	imac: {
		cilium:            apps["cilium"]
		"kuma-zone":       apps["kuma-zone"]
		"argo-workflows":  apps["argo-workflows"]
		"docker-registry": apps["docker-registry"]
		pihole: {}
		traefik: {}
	}
	mbpro: {
		cilium:            apps["cilium"]
		"kuma-zone":       apps["kuma-zone"]
		"argo-workflows":  apps["argo-workflows"]
		"docker-registry": apps["docker-registry"]
		pihole: {}
		traefik: {}
	}
	mini: {
		cilium:            apps["cilium"]
		"kuma-global":     apps["kuma-global"]
		"argo-workflows":  apps["argo-workflows"]
		"docker-registry": apps["docker-registry"]
		pihole: {}
		traefik: {}
	}
}

for gname, cs in groups for cname in cs {
	project: #ArgoProject & {
		"\(cname)": {}
	}

	group: #ArgoGroupCluster & {
		"\(gname)": "\(cname)": {}
	}

	for aname, app in clusters[cname] {
		application: #ArgoApplication & {
			"\(cname)": "\(aname)": app
		}
	}
}
