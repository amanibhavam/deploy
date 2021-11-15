all:
	cue fmt
	cue argocd
	cue kustomize
	git diff o c
