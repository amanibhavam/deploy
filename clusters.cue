package katt

appProject: imac: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "AppProject"
	metadata: {
		name:      "imac"
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

appProject: immanent: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "AppProject"
	metadata: {
		name:      "immanent"
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

appProject: mbpro: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "AppProject"
	metadata: {
		name:      "mbpro"
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

appProject: mini: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "AppProject"
	metadata: {
		name:      "mini"
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

application: "spiral--imac": {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      "spiral--imac"
		namespace: "argocd"
	}
	spec: {
		project: "imac"
		source: {
			repoURL:        "https://github.com/amanibhavam/deploy"
			path:           "imac/deploy"
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

application: "dev--immanent": {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      "dev--immanent"
		namespace: "argocd"
	}
	spec: {
		project: "immanent"
		source: {
			repoURL:        "https://github.com/amanibhavam/deploy"
			path:           "immanent/deploy"
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

application: "spiral--mbpro": {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      "spiral--mbpro"
		namespace: "argocd"
	}
	spec: {
		project: "mbpro"
		source: {
			repoURL:        "https://github.com/amanibhavam/deploy"
			path:           "mbpro/deploy"
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

application: "spiral--mini": {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      "spiral--mini"
		namespace: "argocd"
	}
	spec: {
		project: "mini"
		source: {
			repoURL:        "https://github.com/amanibhavam/deploy"
			path:           "mini/deploy"
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
