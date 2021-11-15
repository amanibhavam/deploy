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

#Common: {
	cilium:            apps["cilium"]
	"argo-workflows":  apps["argo-workflows"]
	"docker-registry": apps["docker-registry"]
	pihole: {}
	traefik: {}

	[string]: {}
}

let clusters = {
	imac: #Common & {
		"kuma-global": apps["kuma-global"]
	}
	mbpro: #Common & {
		"kuma-zone": apps["kuma-zone"]
	}
	mini: #Common & {
		"kuma-zone": apps["kuma-zone"]
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

#ArgoProject: [CLUSTER=string]: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "AppProject"
	metadata: {
		name:      CLUSTER
		namespace: "argocd"
	}
	spec: {
		sourceRepos: [
			"*",
		]
		destinations: [{
			namespace: "*"
			server:    "*"
		}]
		clusterResourceWhitelist: [{
			group: "*"
			kind:  "*"
		}]
		orphanedResources: {
			warn: false
			ignore: [{
				group: "cilium.io"
				kind:  "CiliumIdentity"
			}]
		}
	}
}

#ArgoGroupCluster: [GROUP=string]: [CLUSTER=string]: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      "\(GROUP)--\(CLUSTER)"
		namespace: "argocd"
	}
	spec: {
		project: CLUSTER
		source: {
			repoURL:        "https://github.com/amanibhavam/deploy"
			path:           "c/\(CLUSTER)/deploy"
			targetRevision: "master"
		}
		destination: {
			name:      "in-cluster"
			namespace: "argocd"
		}
		syncPolicy: automated: {
			prune:    true
			selfHeal: true
		}
	}
}

#ArgoApplication: [CLUSTER=string]: [APP=string]: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      "\(CLUSTER)--\(APP)"
		namespace: "argocd"
	}
	spec: {
		project: CLUSTER
		source: {
			repoURL:        string | *'https://github.com/amanibhavam/deploy'
			path:           string | *"c/\(CLUSTER)/\(APP)"
			targetRevision: string | *"master"
		}
		destination: {
			name:      CLUSTER
			namespace: string | *APP
		}
		syncPolicy: {
			automated: {
				prune:    true
				selfHeal: true
			}
			syncOptions: [ string] | *[ "CreateNamespace=true"]
		}
	}
}
