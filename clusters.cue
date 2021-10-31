package katt

let clusterNames = [ "mini", "imac", "mbpro", "immanent"]

let groups = {
	spiral: [ "mini", "imac", "mbpro"]
	dev: [ "immanent"]
}

for c in clusterNames {
	appProject: "\(c)": {}
}

for gname, g in groups for c in g {
	group: "\(gname)": "\(c)": {}
}

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

group: [GROUP=string]: [NAME=string]: {
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
