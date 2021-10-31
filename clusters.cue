package katt

appProject: [NAME=string]: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "AppProject"
	metadata: {
		name:      NAME
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

group: [GROUP=string]: application: [NAME=string]: {
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
	metadata: {
		name:      "\(GROUP)--\(NAME)"
		namespace: "argocd"
	}
	spec: {
		project: NAME
		source: {
			repoURL:        "https://github.com/amanibhavam/deploy"
			path:           "\(NAME)/deploy"
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

appProject: "mini": {}
appProject: "imac": {}
appProject: "mbpro": {}
appProject: "immanent": {}

group: "spiral": application: "mini": {}
group: "spiral": application: "imac": {}
group: "spiral": application: "mbpro": {}
group: "dev": application: "immanent": {}
