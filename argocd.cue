package katt

let groups = {
	spiral: [ "mini", "imac", "mbpro", "katt"]
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
	}
	katt: {
		cilium:           apps["cilium"]
		"kuma-zone":      apps["kuma-zone"]
		"argo-workflows": apps["argo-workflows"]
		"traefik": {}
		"traefik-forward-auth": apps["traefik-forward-auth"]
		"metacontroller": {}
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
