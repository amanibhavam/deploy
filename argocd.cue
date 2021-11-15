package katt

_apps: {
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

_cluster_apps: {
	mini: {
		"kuma-zone": _apps["kuma-zone"]
	}
	imac: {
		"kuma-global": _apps["kuma-global"]
	}
	mbpro: {
		"kuma-zone": _apps["kuma-zone"]
	}
}

_cluster_apps: [string]: _common

_common: {
	cilium:            _apps["cilium"]
	"argo-workflows":  _apps["argo-workflows"]
	"docker-registry": _apps["docker-registry"]
	pihole: {}
	traefik: {}
}

project: #ArgoProject

application: #ArgoApplication

for cname, apps in _cluster_apps {
	project: {
		"\(cname)": {}
	}

	for aname, a in apps {
		application: {
			"\(cname)": "\(aname)": a
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
