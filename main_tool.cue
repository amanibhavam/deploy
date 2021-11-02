package katt

projects: [ for pname, p in project {p}]

clusters: [ for gname, g in group for c in g {c}]

applications: [ for gname, app in application for a in app {a}]

configs: projects + applications
