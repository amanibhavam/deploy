package katt

projects: [ for pname, p in project {p}]

clusters: {
	for cname, apps in application {
		"\(cname)": [ for a in apps {a}]
	}
}
