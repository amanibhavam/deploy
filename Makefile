all:
	cue fmt
	cue dump > main.yaml
	git diff
