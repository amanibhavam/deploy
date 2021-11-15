package katt

deploy: {
	mbpro: _common & {
		"kuma-zone": #DeployKumaZone & {
			_kuma_global_address: "grpcs://100.119.206.78:5685"
		}
		cilium: #DeployCilium & {
			_cilium_cluster_id:        "103"
			_cilium_cluster_ipv4_cidr: "10.83.0.0/16"
		}
	}
	mini: _common & {
		"kuma-zone": #DeployKumaZone & {
			_kuma_global_address: "grpcs://100.119.206.78:5685"
		}
		cilium: #DeployCilium & {
			_cilium_cluster_id:        "101"
			_cilium_cluster_ipv4_cidr: "10.81.0.0/16"
		}
	}
	imac: _common & {
		"kuma-global": #DeployKumaGlobal
		cilium:        #DeployCilium & {
			_cilium_cluster_id:        "102"
			_cilium_cluster_ipv4_cidr: "10.82.0.0/16"
		}
	}

	_common: {
		traefik:           #DeployTraefik
		"docker-registry": #DeployDockerRegistry
		"argo-workflows":  #DeployArgoWorkflows
		pihole:            #DeployPihole
		[string]:          #Kustomization
	}

	[string]: [string]: #Kustomization
	[CNAME=string]: [string]: _cname: CNAME

	#DeployKumaZone: CFG=#Kustomization & {
		_kuma_global_address: string

		resources: ["https://github.com/letfn/katt-kuma/zone?ref=0.0.7"]

		_patches: {
			"deployment-kuma-control-plane": {
				kind: "Deployment"
				name: "kuma-control-plane"
				ops: [{
					op:   "replace"
					path: "/spec/template/spec/containers/0/env/8"
					value: {
						name:  "KUMA_MULTIZONE_ZONE_GLOBAL_ADDRESS"
						value: CFG._kuma_global_address
					}
				}, {
					op:   "replace"
					path: "/spec/template/spec/containers/0/env/9"
					value: {
						name:  "KUMA_MULTIZONE_ZONE_NAME"
						value: CFG._cname
					}
				}]
			}
		}
	}

	#DeployKumaGlobal: #Kustomization & {
		resources: ["https://github.com/letfn/katt-kuma/global?ref=0.0.7"]
	}

	#DeployCilium: CFG=#Kustomization & {
		_cilium_cluster_id:        string
		_cilium_cluster_ipv4_cidr: string

		resources: ["https://github.com/letfn/katt-cilium/base?ref=0.0.7"]

		_patches: {
			"configmap-cilium-config-cluster-mesh": {
				kind: "ConfigMap"
				name: "cilium-config"
				ops: [{
					op:    "replace"
					path:  "/data/cluster-id"
					value: CFG._cilium_cluster_id
				}, {
					op:    "replace"
					path:  "/data/cluster-name"
					value: CFG._cname
				}, {
					op:    "replace"
					path:  "/data/cluster-pool-ipv4-cidr"
					value: CFG._cilium_cluster_ipv4_cidr
				}]
			}
		}
	}

	#DeployPihole: #Kustomization & {
		resources: [
			"https://github.com/letfn/katt-pihole/base?ref=0.0.17",
			"ingress.yaml",
		]
	}

	#DeployTraefik: CFG=#Kustomization & {
		resources: [
			"https://github.com/letfn/katt-traefik/relay?ref=0.0.33",
			"ingress.yaml",
		]

		_patches: {
			"cluster-role-binding": {
				kind: "ClusterRoleBinding"
				name: "traefik"
				ops: [{
					"op":    "replace"
					"path":  "/subjects/0/namespace"
					"value": "traefik-\(CFG._cname)"
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
}

#Kustomization: {
	apiVersion: "kustomize.config.k8s.io/v1beta1"
	kind:       "Kustomization"

	resources?: [...]

	_cname: string

	_patches: {...} | *{}

	patches: [
		for pname, p in _patches {
			path: "patch-\(pname).yaml"
			target: {
				kind: p.kind
				name: p.name
			}
		},
	]

	[string]: _
}
