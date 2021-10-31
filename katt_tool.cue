package katt

projects: [ for pname, p in appProject {p}]

clusters: [ for gname, g in group for c in g { c } ]

configs: projects + clusters
