package katt

#Kustomization: {
	apiVersion: "kustomize.config.k8s.io/v1beta1"
	kind:       "Kustomization"

	resources?: [...]

	patches?: [...]
}

deploy: [string]: [string]: #Kustomization

#DeployKumaZone: #Kustomization & {
	resources: ["https://github.com/letfn/katt-kuma/zone?ref=0.0.7"]

	patches: [{
		path: "patch-deployment-kuma-control-plane.yaml"
		target: {
			kind: "Deployment"
			name: "kuma-control-plane"
		}
	}]
}

#DeployKumaGlobal: #Kustomization & {
	resources: ["https://github.com/letfn/katt-kuma/global?ref=0.0.7"]
}

#DeployCilium: #Kustomization & {
	resources: ["https://github.com/letfn/katt-cilium/base?ref=0.0.7"]

	patches: [{
		path: "patch-configmap-cilium-config-cluster-mesh.yaml"
		target: {
			kind: "ConfigMap"
			name: "cilium-config"
		}
	}]
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

	patches: [{
		path: "patch-cluster-role-binding.yaml"
		target: {
			kind: "ClusterRoleBinding"
			name: "traefik"
		}
	}]
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

_common: {
	cilium:            #DeployCilium
	traefik:           #DeployTraefik
	"docker-registry": #DeployDockerRegistry
	"argo-workflows":  #DeployArgoWorkflows
	pihole:            #DeployPihole
	[string]:          #Kustomization
}

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
