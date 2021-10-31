package katt

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

#ArgoCluster: [GROUP=string]: [CLUSTER=string]: {
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
			path:           "\(CLUSTER)/deploy"
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
