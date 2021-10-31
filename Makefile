all:
	cue fmt
	cue dump > out/main.yaml
	git diff
