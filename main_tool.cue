package katt

projects: [ for pname, p in project {p}]

clusters: [ for gname, g in group for c in g {c}]

applications: [ for gname, app in application for a in app {a}]

deploys: [ for cname, c in deploy for cname, a in c {a}]

configs: projects + applications
