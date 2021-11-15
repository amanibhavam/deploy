package katt

deploy: {
	mbpro: _common & {
		"kuma-zone": #DeployKumaZone
	}
	mini: _common & {
		"kuma-zone": #DeployKumaZone
	}
	imac: _common & {
		"kuma-global": #DeployKumaGlobal
	}
}

deploy: [string]: [string]: #Kustomization

_common: {
	cilium:            #DeployCilium
	traefik:           #DeployTraefik
	"docker-registry": #DeployDockerRegistry
	"argo-workflows":  #DeployArgoWorkflows
	pihole:            #DeployPihole
	[string]:          #Kustomization
}

#Kustomization: {
	apiVersion: "kustomize.config.k8s.io/v1beta1"
	kind:       "Kustomization"

	resources?: [...]

	_patches: {...} | *{}

	patches: [
		for pname, p in _patches {
			path: "\(pname).yaml"
			target: {
				kind: p.kind
				name: p.name
			}
		},
	]
}

#DeployKumaZone: #Kustomization & {
	resources: ["https://github.com/letfn/katt-kuma/zone?ref=0.0.7"]

	_patches: {
		"patch-deployment-kuma-control-plane": {
			kind: "Deployment"
			name: "kuma-control-plane"
			ops: []
		}
	}
}

#DeployKumaGlobal: #Kustomization & {
	resources: ["https://github.com/letfn/katt-kuma/global?ref=0.0.7"]
}

#DeployCilium: #Kustomization & {
	resources: ["https://github.com/letfn/katt-cilium/base?ref=0.0.7"]

	_patches: {
		"patch-configmap-cilium-config-cluster-mesh": {
			kind: "ConfigMap"
			name: "cilium-config"
			ops: []
		}
	}
}

#DeployPihole: #Kustomization & {
	resources: [
		"https://github.com/letfn/katt-pihole/base?ref=0.0.17",
		"ingress.yaml",
	]
}

#DeployTraefik: #Kustomization & {
	resources: [
		"https://github.com/letfn/katt-traefik/relay?ref=0.0.33",
		"ingress.yaml",
	]

	_patches: {
		"patch-cluster-role-binding": {
			kind: "ClusterRoleBinding"
			name: "traefik"
			ops: [{
				"op":    "replace"
				"path":  "/subjects/0/namespace"
				"value": "traefik-mini"
			}]
		}
	}
}

#DeployDockerRegistry: #Kustomization & {
	resources: ["https://github.com/letfn/katt-docker-registry/base?ref=0.0.2"]
}

#DeployArgoWorkflows: #Kustomization & {
	resources: [
		"https://github.com/letfn/katt-argo-workflows/base?ref=0.0.17",
		"ingress.yaml",
	]
}
