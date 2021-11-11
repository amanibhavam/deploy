all:
	cue fmt
	cue dump > o/main.yaml
	git diff
