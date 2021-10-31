package katt

projects: [ for pname, p in cluster {p}]

clusters: [ for gname, g in group for c in g {c}]

configs: projects + clusters
