all:
	cue fmt
	cue dump
	cue kustomize
	git diff o c
