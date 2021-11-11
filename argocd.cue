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
	"2048": {
		spec: destination: namespace: "katt-2048"
	}
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
		cilium:      apps["cilium"]
		"kuma-zone": apps["kuma-zone"]
		pihole: {}
		traefik: {}
		"2048": apps["2048"]
	}
	mbpro: {
		cilium:      apps["cilium"]
		"kuma-zone": apps["kuma-zone"]
		pihole: {}
		"2048": apps["2048"]
	}
	mini: {
		cilium:        apps["cilium"]
		"kuma-global": apps["kuma-global"]
		pihole: {}
		"docker-registry": apps["docker-registry"]
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
