package boot

import (
	"github.com/defn/boot"
)

// ArgoCD Applications
app: {
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
	mini: {
		"kuma-zone": {
			app:    app["kuma-zone"]
			deploy: #DeployKumaZone & {
				_kuma_global_address: "grpcs://100.119.206.78:5685"
			}
		}
		cilium: {
			deploy: #DeployCilium & {
				_cilium_cluster_id:        "101"
				_cilium_cluster_ipv4_cidr: "10.81.0.0/16"
			}
		}
	}
	imac: {
		"kuma-global": {
			app:    app["kuma-global"]
			deploy: #DeployKumaGlobal
		}
		cilium: {
			deploy: #DeployCilium & {
				_cilium_cluster_id:        "102"
				_cilium_cluster_ipv4_cidr: "10.82.0.0/16"
			}
		}
	}
	mbpro: {
		"kuma-zone": {
			app:    app["kuma-zone"]
			deploy: #DeployKumaZone & {
				_kuma_global_address: "grpcs://100.119.206.78:5685"
			}
		}
		cilium: {
			deploy: #DeployCilium & {
				_cilium_cluster_id:        "103"
				_cilium_cluster_ipv4_cidr: "10.83.0.0/16"
			}
		}
	}

	// Every cluster runs, deploys a common set of apps
	[string]: {
		cilium: app: app["cilium"]
		traefik: app: {}
		traefik: deploy:           #DeployTraefik
		"argo-workflows": app:     app["argo-workflows"]
		"argo-workflows": deploy:  #DeployArgoWorkflows
		"docker-registry": app:    app["docker-registry"]
		"docker-registry": deploy: #DeployDockerRegistry
		pihole: app: {}
		pihole: deploy: #DeployPihole
	}

	// Base schemas for projects, apps, deploys
	[CLUSTER=string]: [string]: project: boot.#ArgoProject & {
		_cluster: CLUSTER
	}
	[CLUSTER=string]: [APP=string]: app: boot.#ArgoApplication & {
		_cluster: CLUSTER
		_app:     APP
	}
	[CLUSTER=string]: [APP=string]: deploy: boot.#DeployBase & {
		_domain: "defn.ooo"
		_cname:  CLUSTER
		_aname:  APP
	}
}

#DeployKumaZone: CFG=boot.#DeployBase & {
	_kuma_global_address: string

	_upstream: "https://github.com/letfn/katt-kuma/zone?ref=0.0.7"

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

#DeployKumaGlobal: boot.#DeployBase & {
	_upstream: "https://github.com/letfn/katt-kuma/global?ref=0.0.7"
}

#DeployCilium: CFG=boot.#DeployBase & {
	_cilium_cluster_id:        string
	_cilium_cluster_ipv4_cidr: string

	_upstream: "https://github.com/letfn/katt-cilium/base?ref=0.0.7"

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

#DeployPihole: CFG=boot.#DeployBase & {
	_upstream: "https://github.com/letfn/katt-pihole/base?ref=0.0.17"

	_resources: [{
		apiVersion: "traefik.containo.us/v1alpha1"
		kind:       "IngressRoute"
		metadata: {
			name:      "pihole"
			namespace: "pihole"
		}
		spec: {
			entryPoints: [ "web"]
			routes: [{
				match: "Host(`pihole.\(CFG._cname).\(CFG._domain)`)"
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
	_upstream: "https://github.com/letfn/katt-traefik/relay?ref=0.0.33"

	_resources: [{
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
				match: "Host(`traefik.\(CFG._cname).\(CFG._domain)`)"
				kind:  "Rule"
				services: [{
					name: "api@internal"
					kind: "TraefikService"
				}]
			}]
		}
	}]

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

#DeployDockerRegistry: boot.#DeployBase & {
	_upstream: "https://github.com/letfn/katt-docker-registry/base?ref=0.0.2"
}

#DeployArgoWorkflows: CFG=boot.#DeployBase & {
	_upstream: "https://github.com/letfn/katt-argo-workflows/base?ref=0.0.17"

	_resources: [{
		apiVersion: "traefik.containo.us/v1alpha1"
		kind:       "Middleware"
		metadata: {
			name:      "traefik-forward-auth"
			namespace: "argo"
		}
		spec: {
			forwardAuth: {
				address: http:
					authResponseHeaders: ["X-Forwarded-User"] //traefik-forward-auth.traefik.svc.cluster.local:4181
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
				match: "Host(`argo.\(CFG._cname).\(CFG._domain)`)"
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
