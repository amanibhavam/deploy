package boot

import (
	"github.com/defn/boot"
)

// Boot configuration
cfg: argocd: boot.#ArgoCD & {
	projects: [
		for cname, c in cluster {
			boot.#ArgoProject & {
				metadata: bootCluster: cname
			}
		},
	]
	clusters: {
		for cname, c in cluster {
			"\(cname)": [
				for aname, a in c {a.app},
			]
		}
	}
}

cfg: kustomize: boot.#Kustomize & {
	clusters: {
		for cname, c in cluster {
			"\(cname)": [
				for aname, a in c {a.deploy},
			]
		}
	}
}

// ArgoCD Applications
application: {
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

cluster: {
	// Unique apps, deploys
	imac: {
		"kuma-global": {
			app:    application["kuma-global"]
			deploy: #DeployKumaGlobal
		}
		cilium: {
			deploy: #DeployCilium & {
				cilium_cluster_id:        "102"
				cilium_cluster_ipv4_cidr: "10.82.0.0/16"
			}
		}
	}
	mini: {
		"kuma-zone": {
			app:    application["kuma-zone"]
			deploy: #DeployKumaZone & {
				kuma_global_address: "grpcs://100.119.206.78:5685"
			}
		}
		cilium: {
			deploy: #DeployCilium & {
				cilium_cluster_id:        "101"
				cilium_cluster_ipv4_cidr: "10.81.0.0/16"
			}
		}
	}
	mbpro: {
		"kuma-zone": {
			app:    application["kuma-zone"]
			deploy: #DeployKumaZone & {
				kuma_global_address: "grpcs://100.119.206.78:5685"
			}
		}
		cilium: {
			deploy: #DeployCilium & {
				cilium_cluster_id:        "103"
				cilium_cluster_ipv4_cidr: "10.83.0.0/16"
			}
		}
	}

	// Every cluster runs, deploys a common set of apps
	[string]: {
		cilium: app: application["cilium"]
		traefik: app: {}
		traefik: deploy:           #DeployTraefik
		"argo-workflows": app:     application["argo-workflows"]
		"argo-workflows": deploy:  #DeployArgoWorkflows
		"docker-registry": app:    application["docker-registry"]
		"docker-registry": deploy: #DeployDockerRegistry
		pihole: app: {}
		pihole: deploy: #DeployPihole
	}

	// ArgoCD app
	[CLUSTER=string]: [APP=string]: {
		app: boot.#ArgoApplication & {
			metadata: {
				bootCluster: CLUSTER
				bootApp:     APP
			}
		}
	}

	// Kustomize app-bundle
	[CLUSTER=string]: [APP=string]: {
		deploy: boot.#DeployBase & {
			domain: "defn.ooo"
			cname:  CLUSTER
			aname:  APP
		}
	}
}

#DeployKumaZone: CFG=boot.#DeployBase & {
	kuma_global_address: string

	upstream: "https://github.com/letfn/katt-kuma/zone?ref=0.0.7"

	patches: {
		"deployment-kuma-control-plane": {
			kind: "Deployment"
			name: "kuma-control-plane"
			ops: [{
				op:   "replace"
				path: "/spec/template/spec/containers/0/env/8"
				value: {
					name:  "KUMA_MULTIZONE_ZONE_GLOBAL_ADDRESS"
					value: CFG.kuma_global_address
				}
			}, {
				op:   "replace"
				path: "/spec/template/spec/containers/0/env/9"
				value: {
					name:  "KUMA_MULTIZONE_ZONE_NAME"
					value: CFG.cname
				}
			}]
		}
	}
}

#DeployKumaGlobal: boot.#DeployBase & {
	upstream: "https://github.com/letfn/katt-kuma/global?ref=0.0.7"
}

#DeployCilium: CFG=boot.#DeployBase & {
	cilium_cluster_id:        string
	cilium_cluster_ipv4_cidr: string

	upstream: "https://github.com/letfn/katt-cilium/base?ref=0.0.7"

	patches: {
		"configmap-cilium-config-cluster-mesh": {
			kind: "ConfigMap"
			name: "cilium-config"
			ops: [{
				op:    "replace"
				path:  "/data/cluster-id"
				value: CFG.cilium_cluster_id
			}, {
				op:    "replace"
				path:  "/data/cluster-name"
				value: CFG.cname
			}, {
				op:    "replace"
				path:  "/data/cluster-pool-ipv4-cidr"
				value: CFG.cilium_cluster_ipv4_cidr
			}]
		}
	}
}

#DeployPihole: CFG=boot.#DeployBase & {
	upstream: "https://github.com/letfn/katt-pihole/base?ref=0.0.17"

	resources: [{
		apiVersion: "traefik.containo.us/v1alpha1"
		kind:       "IngressRoute"
		metadata: {
			name:      "pihole"
			namespace: "pihole"
		}
		spec: {
			entryPoints: [ "web"]
			routes: [{
				match: "Host(`pihole.\(CFG.cname).\(CFG.domain)`)"
				kind:  "Rule"
				services: [{
					name: "pihole-web"
					port: 80
				}]
			}]
		}
	}]
}

#DeployTraefik: CFG=boot.#DeployBase & {
	upstream: "https://github.com/letfn/katt-traefik/relay?ref=0.0.33"

	resources: [{
		apiVersion: "traefik.containo.us/v1alpha1"
		kind:       "IngressClass"
		metadata: {
			name: "traefik"
		}
		spec: controller: "traefik.io/ingress-controller"
	}, {
		apiVersion: "traefik.containo.us/v1alpha1"
		kind:       "IngressRoute"
		metadata: {
			name: "traefik"
		}
		spec: {
			entryPoints: [ "web"]
			routes: [{
				match: "Host(`traefik.\(CFG.cname).\(CFG.domain)`)"
				kind:  "Rule"
				services: [{
					name: "api@internal"
					kind: "TraefikService"
				}]
			}]
		}
	}]

	patches: {
		"cluster-role-binding": {
			kind: "ClusterRoleBinding"
			name: "traefik"
			ops: [{
				"op":    "replace"
				"path":  "/subjects/0/namespace"
				"value": "traefik-\(CFG.cname)"
			}]
		}
	}
}

#DeployDockerRegistry: boot.#DeployBase & {
	upstream: "https://github.com/letfn/katt-docker-registry/base?ref=0.0.2"
}

#DeployArgoWorkflows: CFG=boot.#DeployBase & {
	upstream: "https://github.com/letfn/katt-argo-workflows/base?ref=0.0.17"

	resources: [{
		apiVersion: "traefik.containo.us/v1alpha1"
		kind:       "Middleware"
		metadata: {
			name:      "traefik-forward-auth"
			namespace: "argo"
		}
		spec: {
			forwardAuth: {
				address: http:
					authResponseHeaders: ["X-Forwarded-User"]
			}
		}
	}, {
		apiVersion: "traefik.containo.us/v1alpha1"
		kind:       "IngressRoute"
		metadata: {
			name:      "argowf"
			namespace: "argo"
		}
		spec: {
			tls: certResolver: "letsencrypt"
			entryPoints: [ "websecure"]
			routes: [{
				match: "Host(`argo.\(CFG.cname).\(CFG.domain)`)"
				kind:  "Rule"
				services: [{
					name:   "argo-server"
					port:   2746
					scheme: "https"
				}]
				middlewares: [{
					name: "traefik-forward-auth"
				}]
			}]
		}
	}]
}
