/**
 * General layout structure styles.
 * Template-based CSS for both modern and legacy builds.
 */

body {
{{- if .Site.Params.legacyMode }}
    margin: 0;
    padding: 0;
{{- else }}
    margin: 0 auto;
{{- end }}
}

#nb-site {
{{- if .Site.Params.legacyMode }}
    width: 100%;
{{- end }}
}

#nb-site > .site {
}

#nb-header {
{{- if .Site.Params.legacyMode }}
    width: 100%;
    margin: 0;
    padding: 0;
{{- end }}
}
#nb-header > .pad {
}
    #nb-header .headings {
        float: left;
    }
    [dir=rtl] #nb-header .headings {
        float: right;
    }

    #nb-header .tools {
        float: right;
        text-align: right;
    }
    [dir=rtl] #nb-header .tools {
        float: left;
        text-align: left;
    }

#nb-footer {
    clear: both;
{{- if .Site.Params.legacyMode }}
    width: 100%;
{{- end }}
}
#nb-footer > .pad {
}

{{- if .Site.Params.legacyMode }}
/* Simple column system using floats */
.container-row {
    width: 100%;
    overflow: hidden; /* clearfix */
}

.container-row:after {
    content: ".";
    display: block;
    height: 0;
    clear: both;
    visibility: hidden;
}
{{- else }}
.container-row {
	display: flex;
	flex-flow: row nowrap;
}
.col-1 { flex-grow: 1; }
.col-2 { flex-grow: 2; }
.col-3 { flex-grow: 3; }
.col-4 { flex-grow: 4; }
.col-5 { flex-grow: 5; }
.col-6 { flex-grow: 6; }
.col-7 { flex-grow: 7; }
.col-8 { flex-grow: 8; }
.col-9 { flex-grow: 9; }
.col-10 { flex-grow: 10; }
.col-11 { flex-grow: 11; }
.col-12 { flex-grow: 12; }
{{- end }}
