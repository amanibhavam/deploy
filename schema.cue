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
	metadata: name: "\(CLUSTER)--\(APP)"
	namespace: "argocd"
	spec: project:   CLUSTER
	source: repoURL: string | *'https://github.com/amanibhavam/deploy'
	path:           string | *"\(CLUSTER)/\(APP)"
	targetRevision: string | *"master"
	destination: {
		name:      CLUSTER
		namespace: string | *APP
	}
	syncPolicy: automated: prune: true
	selfHeal: true
	syncOptions: [{CreateNamespace: bool | *true}]
}
