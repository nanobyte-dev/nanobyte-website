/**
 * Main design styles for the site layout and components.
 * Template-based CSS for both modern and legacy builds.
 */


/* header
********************************************************************/

#nb-header {
{{- if .Site.Params.legacyMode }}
    text-align: center;
    width: 100%;
    margin: 0;
    padding: 0;
{{- end }}
}

#nb-header .nb-logo {
{{- if .Site.Params.legacyMode }}
    width: 100%;
    overflow: hidden;
    line-height: 0; /* remove extra space below inline image */
    margin-bottom: 0.5rem;
{{- else }}
	height: 18rem;
{{- end }}
}

#nb-header .nb-logo img {
{{- if .Site.Params.legacyMode }}
    display: block;
    width: 100%;
    height: auto;
    margin: 0;
{{- else }}
	display: block;
	height: 100%;
	object-fit: cover;
	margin: 0 auto;
	margin-top: -2rem;
{{- end }}
}

#nb-header .nb-nav {
	position: relative;
	z-index: 1;
	margin-top: -3.5rem;
	margin-bottom: 0.5rem;
{{- if .Site.Params.legacyMode }}
    width: 100%;
    margin: 0.25rem 0 1.25rem 0;
{{- else }}
	width: 100%;
	margin-top: .25rem;
	margin-bottom: 1.25rem;
{{- end }}
}

#nb-header .nb-nav ul {
{{- if .Site.Params.legacyMode }}
    margin: 0 auto;
    padding: 0;
    text-align: center;
{{- else }}
	display:flex;
	flex-flow: row wrap;
	justify-content: center;
	margin: 0 auto;
	padding: 0;
{{- end }}
}

#nb-header .nb-nav ul > li {
{{- if .Site.Params.legacyMode }}
    display: inline;
    margin: 0 0.5rem;
{{- else }}
	display: inline-block;
	margin: .25rem .5rem;
{{- end }}
}

#nb-header .nb-nav ul > li a {
	color: #c8c5cd;
	font-size: 0.95em;
	letter-spacing: 0.03em;
	padding: .25rem .5rem;
	border-radius: .25rem;
	transition: color 0.15s, background 0.15s;
{{- if .Site.Params.legacyMode }}
    text-decoration: none;
{{- end }}
}

#nb-header .nb-nav ul > li a:hover {
	color: #F0A9B8;
	background: rgba(255, 255, 255, 0.06);
	text-decoration: none;
	border-radius: .25rem;
}

{{- if not .Site.Params.legacyMode }}
#nb-header .nb-nav ul > li:not(:last-child):after {
	margin-left: 1rem;
	color: #c8c5cd;
	opacity: .5;
	content: "|";
}
{{- end }}

#nb-header .headings {
    margin-bottom: 2.1em;
}
#nb-header h1 {
    margin-bottom: 0;
    font-size: 1.5em;
}
#nb-header h1 a {
    text-decoration: none;
    color: #F0A9B8;
    background-color: inherit;
}
#nb-header p.claim {
    margin-bottom: 0;
}
#nb-header h2 {
    margin-bottom: 0;
    font-size: 1.125em;
}

#nb-header .tools {
    margin-bottom: 2.1em;
}
#nb-header .tools ul {
    margin-bottom: 0;
}
#nb-header .tools ul li {
    display: inline;
}

#nb-header form.search {
    margin: .5em 0 0;
    display: block;
}
#nb-header form.search #nb-search-input {
    width: 12em;
    margin-right: .5em;
}
[dir=rtl] #nb-header form.search #nb-search-input {
    margin-right: 0;
    margin-left: .5em;
}

#nb-header div.breadcrumbs {
    margin-bottom: .3em;
}
#nb-header div.breadcrumbs a {
    color: #F0A9B8;
    background-color: inherit;
}

.user_logged_in {
	position: absolute;
	right: 1rem;
	top: .25rem;
}

/* tools
********************************************************************/

/* make wiki links look the same as tool links in tool bars */
#nb-usertools a.wikilink1,
#nb-pagetools a.wikilink1,
#nb-usertools a.wikilink2,
#nb-pagetools a.wikilink2 {
    color: #F0A9B8;
    border-bottom-width: 0;
}
#nb-usertools a.wikilink2:hover,
#nb-pagetools a.wikilink2:hover,
#nb-usertools a.wikilink2:active,
#nb-pagetools a.wikilink2:active,
#nb-usertools a.wikilink2:focus,
#nb-pagetools a.wikilink2:focus {
    text-decoration: underline;
}

/* highlight selected tool */
/* before Greebo: */
.mode_admin a.action.admin,
.mode_login a.action.login,
.mode_register a.action.register,
.mode_profile a.action.profile,
.mode_recent a.action.recent,
.mode_index a.action.index,
.mode_media a.action.media,
.mode_revisions a.action.revs,
.mode_backlink a.action.backlink,
.mode_subscribe a.action.subscribe,
/* since Greebo: */
.mode_admin .action.admin a,
.mode_login .action.login a,
.mode_register .action.register a,
.mode_profile .action.profile a,
.mode_recent .action.recent a,
.mode_index .action.index a,
.mode_media .action.media a,
.mode_revisions .action.revs a,
.mode_backlink .action.backlink a,
.mode_subscribe .action.subscribe a {
    font-weight: bold;
}

/*____________ page tools ____________*/

/* before Greebo: */
#nb-pagetools ul li a.action.top,
/* since Greebo: */
#nb-pagetools ul li.action.top a {
    display: none;
}
/* before Greebo: */
[dir=rtl] #nb-pagetools ul li a.action.top,
/* since Greebo: */
[dir=rtl] #nb-pagetools ul li.action.top a {
    display: none;
}

/* hide background images from menu items inserted via plugins */
#nb-pagetools ul li a {
    background-image: none !important;
}
#nb-pagetools ul li a::before {
    content: none !important;
}


/* sidebar
********************************************************************/

.sidepanel {
{{- if .Site.Params.legacyMode }}
    float: left;
    width: 15rem;
    padding: 1.25rem;
{{- else }}
	align-self: stretch;
	background: transparent;
	border-right: 1px solid rgba(255, 255, 255, 0.06);
{{- end }}
}

.sidepanel nav {
	margin-top: .75rem;
}

.sidepanel h3 {
	margin: 1rem 0 0 0;
	padding: .5rem 0 .4rem 0;
	font-size: 0.8rem;
	text-transform: uppercase;
	letter-spacing: 0.08em;
	color: #aaa;
	background: transparent;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
	border-radius: 0;
}

.sidepanel nav ul {
	margin: 0;
{{- if .Site.Params.legacyMode }}
    padding: 0.35rem 0;
    background: transparent;
    border-radius: 0 0 0.35rem 0.35rem;
    list-style: none;
{{- else }}
	padding: .25rem 0;
	border-radius: 0;
	background: transparent;
{{- end }}
}

.sidepanel nav ul li {
	display: block;
	width: 100%;
	list-style: none;
{{- if .Site.Params.legacyMode }}
    margin: 0;
{{- else }}
	margin-left: 0;
{{- end }}
}

.sidepanel nav ul li.level1 {
	margin-left: 0;
}

.sidepanel nav ul li .curid a {
	background: rgba(45, 40, 66, 0.7);
}

.sidepanel nav ul li a {
{{- if .Site.Params.legacyMode }}
    color: #e5e3e8;
    padding: 0.25rem 0.5rem 0.25rem 1.5rem;
    display: block;
    text-decoration: none;
{{- else }}
	color: #e5e3e8 !important;
	padding: .35rem .5rem .35rem 1rem;
	display: block;
	border-radius: .25rem;
	margin: 1px 0;
	transition: background 0.15s;
	font-size: 0.9rem;
{{- end }}
}

.sidepanel nav ul li a:hover {
	background: rgba(78, 52, 138, 0.4);
	text-decoration: none;
}

.sidepanel nav ul li a.active {
	background: rgba(240, 169, 184, 0.12);
	color: #F0A9B8 !important;
	border-left: 2px solid #F0A9B8;
	padding-left: calc(1rem - 2px);
	font-weight: bold;
}

/* Nested navigation */
.sidepanel nav ul ul {
	padding: 0;
	margin: 0;
	background: transparent;
	border-radius: 0;
}

.sidepanel nav ul ul li a,
.sidepanel nav ul ul li a.active {
	padding-left: 2rem;
	font-size: 0.9rem;
{{- if .Site.Params.legacyMode }}
    color: #c8c5cd;
{{- else }}
	color: #c8c5cd !important;
{{- end }}
}

.sidepanel nav ul ul li a:hover {
	background: rgba(78, 52, 138, 0.4);
}

.mode_admin .sidepanel a.action.admin,
.mode_login .sidepanel a.action.login,
.mode_register .sidepanel a.action.register,
.mode_profile .sidepanel a.action.profile,
.mode_recent .sidepanel a.action.recent,
.mode_index .sidepanel a.action.index,
.mode_media .sidepanel a.action.media,
.mode_revisions .sidepanel a.action.revs,
.mode_backlink .sidepanel a.action.backlink,
.mode_subscribe .sidepanel a.action.subscribe,
.mode_admin .sidepanel .action.admin a,
.mode_login .sidepanel .action.login a,
.mode_register .sidepanel .action.register a,
.mode_profile .sidepanel .action.profile a,
.mode_recent .sidepanel .action.recent a,
.mode_index  .sidepanel .action.index a,
.mode_media .sidepanel .action.media a,
.mode_revisions .sidepanel .action.revs a,
.mode_backlink .sidepanel .action.backlink a,
.mode_subscribe .sidepanel .action.subscribe a {
	background: rgba(45, 40, 66, 0.7);
}

/* hamburger - hidden by default, shown on mobile */
#sidepanel_hamburger {
	color: #e5e3e8;
	display: none;
}

/* search */
#nb-search {
	display: block;
{{- if .Site.Params.legacyMode }}
    margin-bottom: 1rem;
{{- end }}
}

#nb-search .no{
{{- if .Site.Params.legacyMode }}
    width: 100%;
    white-space: nowrap;
{{- else }}
	display: flex;
	flex-flow: row nowrap;
{{- end }}
}

#nb-search .no input.edit {
{{- if .Site.Params.legacyMode }}
    width: 60%;
    background: transparent;
    border: 1px solid #222038;
    border-radius: 0.35rem 0 0 0.35rem;
    color: #e5e3e8;
    padding: 0.25rem 0.5rem;
    vertical-align: middle;
    display: inline-block;
{{- else }}
	flex-grow: 1;
	background: #0d0b14;
	border: 1px solid rgba(255, 255, 255, 0.08);
	border-radius: .5rem 0 0 .5rem;
	color: #e5e3e8;
	padding: .5rem .75rem;
	font-size: 0.9rem;
	transition: border-color 0.2s, box-shadow 0.2s;
{{- end }}
}

#nb-search .no input.edit:focus {
	border-color: #F0A9B8;
	box-shadow: 0 0 8px rgba(240, 169, 184, 0.2);
	outline: none;
}

#nb-search .no input.edit::placeholder {
	color: #666;
}

#nb-search .no button {
{{- if .Site.Params.legacyMode }}
    background: #4e348a;
    border: 1px solid #222038;
    border-radius: 0.35rem;
    color: #e5e3e8;
    padding: 0.25rem 0.5rem;
    margin-left: -0.35rem;
    vertical-align: middle;
    display: inline-block;
{{- else }}
	flex-shrink: 0;
	background: #4e348a;
	border: none;
	border-radius: 0 .5rem .5rem 0;
	color: #e5e3e8;
	padding: .5rem .75rem;
	font-size: 0.9rem;
	margin-left: 0;
	letter-spacing: 0.02em;
{{- end }}
}

#nb-search .no button:hover {
	background: #6a4eaa;
{{- if not .Site.Params.legacyMode }}
	box-shadow: 0 0 .35rem #111;
{{- end }}
}

{{- if not .Site.Params.legacyMode }}
#nb-search .no button:focus {
	background: #422d71;
	box-shadow: none;
}
{{- end }}

/* toc */

#nb-toc {
	margin: 0 0 1rem 1rem;
	padding: .25rem;
	width: 16rem;
	background: transparent;
	border-radius: .5rem;
	text-align: left;
}

/* content
********************************************************************/

.page {
    word-wrap: break-word;
	text-align: justify;
}

/* license note in footer and under edit window */
div.license {
    font-size: 93.75%;
}

.wrapper {
    padding-bottom: 1rem;
	background: transparent;
{{- if .Site.Params.legacyMode }}
    min-height: 60vh;
    overflow: hidden; /* clearfix for floats */
{{- else }}
	box-shadow: none;
	display: flex;
	flex-flow: row nowrap;
    align-items: stretch;
	min-height: 60vh;
{{- end }}
}

{{- if not .Site.Params.legacyMode }}
.wrapper .sidepanel {
	width: 18rem;
	padding: 1.25rem;
}
{{- end }}

.wrapper .main {
{{- if .Site.Params.legacyMode }}
    overflow: hidden; /* establish new block formatting context for float */
    padding: 1em;
    margin-right: 2em;
    min-height: 15rem;
{{- else }}
	margin: 0;
	padding: 2rem 2.5rem;
	flex-grow: 1;
	min-height: 15rem;
	background: transparent;
{{- end }}
}


/* footer
********************************************************************/

#nb-footer {
{{- if .Site.Params.legacyMode }}
    clear: both;
    background: #0d0b14;
    text-align: center;
    padding: 1.5rem;
{{- else }}
    background: #0d0b14;
	text-align: center;
	padding: 2rem 1.5rem 1rem;
	box-shadow: inset 0 7px 9px -1rem black;
	border-top: 1px solid rgba(255, 255, 255, 0.04);
{{- end }}
}

#nb-footer > .container {
{{- if .Site.Params.legacyMode }}
    text-align: center;
{{- else }}
	text-align: left;
	display: flex;
	flex-flow: row nowrap;
	justify-content: center;
	align-items: flex-start;
	gap: 10%;
{{- end }}
}

{{- if .Site.Params.legacyMode }}
#nb-footer > .container > * {
    display: inline-block;
    vertical-align: top;
    margin: 0 2rem;
    min-width: 12rem;
}

#nb-footer nav ul {
    list-style: none;
    padding: 0;
    margin: 0.5rem 0;
}

#nb-footer nav ul li {
    margin: 0.25rem 0;
}

#nb-footer nav ul li a {
    color: #F0A9B8;
    text-decoration: none;
}

#nb-footer nav ul li a:hover {
    text-decoration: underline;
}
{{- end }}

{{- if not .Site.Params.legacyMode }}
#nb-footer h3 {
	font-size: 0.75rem;
	text-transform: uppercase;
	letter-spacing: 0.1em;
	color: #888;
	margin-bottom: 0.75rem;
}

#nb-footer nav ul li {
	margin: 0.35rem 0;
}

#nb-footer nav ul li a {
	color: #aaa;
	font-size: 0.9rem;
	transition: color 0.15s;
}

#nb-footer nav ul li a:hover {
	color: #F0A9B8;
}
{{- end }}

#nb-footer .doc,
#nb-footer .license {
	color: #555;
	font-size: 0.8rem;
	margin-top: 1.5rem;
	padding-top: 1rem;
	border-top: 1px solid rgba(255, 255, 255, 0.04);
}
#nb-footer .top {
}
#nb-footer .license img {
    margin: 0 .5em 0 0;
    float: none;
}

.invisible_footer {
	display: block;
	width: 100%;
	background: #0d0b14;
}

/* Breadcrumbs */
.breadcrumbs {
    margin-bottom: 1.5rem;
    font-size: 0.9rem;
}

.breadcrumbs ol {
    list-style: none;
    padding: 0;
    margin: 0;
}

.breadcrumbs li {
    display: inline;
    margin: 0 0.25rem 0 0;
}

.breadcrumbs li:after {
    content: "\203A";
    margin-left: 0.5rem;
    color: #666;
}

.breadcrumbs li:last-child:after {
    content: "";
}

.breadcrumbs a {
    color: #F0A9B8;
    text-decoration: none;
}

.breadcrumbs a:hover {
    text-decoration: underline;
}

.breadcrumbs li.active {
    color: #c8c5cd;
}

/* Sitemap */
.sitemap-content {
    margin-top: 2rem;
}

.sitemap-section {
    margin-bottom: 3rem;
}

.sitemap-section h2 {
    color: #F0A9B8;
    border-bottom: 2px solid rgba(172, 125, 205, 0.3);
    padding-bottom: 0.5rem;
    margin-bottom: 1rem;
}

.sitemap-section h2 a {
    color: inherit;
    text-decoration: none;
}

.sitemap-section h2 a:hover {
    text-decoration: underline;
}

.sitemap-section ul {
    list-style: none;
    padding-left: 1.5rem;
}

.sitemap-section li {
    margin-bottom: 0.5rem;
}

.sitemap-section li a {
    color: #e5e3e8;
    text-decoration: none;
}

.sitemap-section li a:hover {
    color: #F0A9B8;
    text-decoration: underline;
}

/* Article List (section index pages) */
.page-list {
    margin-top: 2rem;
}

.page-list h2 {
    color: #F0A9B8;
    border-bottom: 2px solid rgba(172, 125, 205, 0.3);
    padding-bottom: 0.5rem;
    margin-bottom: 1.5rem;
}

.article-list {
    list-style: none;
    padding: 0;
}

.article-list li {
    margin-bottom: 2rem;
    padding: 1.5rem;
    background: transparent;
    border: 1px solid rgba(255, 255, 255, 0.05);
    border-left: 4px solid #ac7dcd;
    border-radius: 0.5rem;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    transition: border-left-color 0.2s, box-shadow 0.2s, transform 0.2s;
}

.article-list li:hover {
    border-left-color: #F0A9B8;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
    transform: translateY(-1px);
}

.article-list a {
    display: block;
    text-decoration: none;
}

.article-title {
    display: block;
    font-size: 1.3rem;
    font-weight: bold;
    color: #F0A9B8;
    margin-bottom: 0.5rem;
}

.article-summary {
    display: block;
    color: #c8c5cd;
    line-height: 1.6;
}

.article-list a:hover .article-title {
    text-decoration: underline;
}

/* Pagination (prev/next navigation) */
.pagination {
{{- if .Site.Params.legacyMode }}
    overflow: hidden;
{{- end }}
    padding: 1.5rem 0;
}

.pagination a {
    color: #F0A9B8;
    text-decoration: none;
    padding: 0.5rem 1rem;
    background: transparent;
    border-radius: 0.5rem;
    border: 1px solid rgba(255, 255, 255, 0.06);
    transition: background 0.2s, transform 0.15s;
}

.pagination a:hover {
    background: #4e348a;
    transform: translateY(-1px);
}

.pagination .prev {
    float: left;
}

.pagination .next {
    float: right;
}

/* Page footer (back to top link) */
.page-footer {
    text-align: center;
    margin-top: 2rem;
    padding-top: 2rem;
    border-top: 1px solid #252035;
    clear: both;
}

.back-to-top {
    color: #F0A9B8;
    text-decoration: none;
    font-size: 0.9rem;
}

.back-to-top:hover {
    text-decoration: underline;
}

/* Table of Contents */
#toc {
    background: #252040;
    border-radius: 0.5rem;
    border: 1px solid rgba(255, 255, 255, 0.06);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
    padding: 1.25rem 1.5rem;
    margin: 1.5rem 0;
}

#toc h2 {
    margin-top: 0;
    font-size: 1.2rem;
    color: #ac7dcd;
}

#toc ul {
    list-style: none;
    padding-left: 0;
    margin-bottom: 0;
}

#toc ul ul {
    padding-left: 1.5rem;
}

#toc li {
    margin: 0.25rem 0;
}

#toc a {
    color: #e5e3e8;
    text-decoration: none;
}

#toc a:hover {
    color: #F0A9B8;
    text-decoration: underline;
}

/* Filenames for code blocks */
dl.code,
dl.file {
    margin: 0.5rem 2rem 1rem 2rem;
    max-width: 100%;
}

dl.code dt,
dl.file dt {
    background-color: #0d0b14;
    border-radius: 0.5rem 0.5rem 0 0;
    color: #c8c5cd;
    display: inline-block;
    padding: 0.3em 0.5em;
    margin-left: 0;
    font-family: "Cascadia Code", Consolas, "Andale Mono WT", "Andale Mono", "Bitstream Vera Sans Mono", "Nimbus Mono L", Monaco, "Courier New", monospace;
    font-size: 0.9em;
}

dl.code dd,
dl.file dd {
    margin: 0;
}

dl.code dd .highlight,
dl.file dd .highlight {
    margin: 0;
    border-radius: 0 0.5rem 0.5rem 0.5rem;
}

{{- if .Site.Params.legacyMode }}
/* Code blocks */
pre,
code,
samp,
kbd {
    font-family: "Cascadia Code", Consolas, "Andale Mono WT", "Andale Mono", "Bitstream Vera Sans Mono", "Nimbus Mono L", Monaco, "Courier New", monospace;
    font-size: 1em;
    background-color: #0d0b14;
    color: #c8c5cd;
    direction: ltr;
    text-align: left;
}

pre {
    margin: 0.5rem 2rem 1rem 2rem;
    border: 1px solid #222038;
    border-radius: 0.5rem;
    padding: 0.5em 1em;
    overflow-x: auto;
    overflow-y: visible;
    word-wrap: normal;
    line-height: 1.4;
}

/* Inline code */
p code,
li code,
td code,
h1 code,
h2 code,
h3 code,
h4 code,
h5 code,
h6 code {
    background-color: #0d0b14;
    padding: 0.1em 0.3em;
    border-radius: 0.25rem;
}

/* Remove padding for code inside syntax highlighted blocks */
.highlight code {
    padding: 0;
    background-color: transparent;
}

/* Code blocks with syntax highlighting */
.highlight {
    margin: 0.5rem 2rem 1rem 2rem;
    border-radius: 0.5rem;
    background-color: #0d0b14;
    overflow-x: auto;
    overflow-y: visible;
    max-width: 100%;
}

.highlight pre {
    background: transparent;
    border: none;
    margin: 0;
    padding: 0.5em 1em;
    overflow: visible;
}

/* Override Chroma's background */
.chroma {
    background-color: #0d0b14;
}

/* Line numbers table - remove all borders and fix alignment */
.highlight .lntable {
    border-spacing: 0;
    padding: 0;
    margin: 0;
    border: 0;
    width: 100%;
    max-width: 100%;
    display: table;
    table-layout: fixed;
}

.highlight .lntd {
    padding: 0;
    margin: 0;
    border: 0;
    vertical-align: top;
}

/* Line numbers column */
.highlight .lnt,
.highlight .ln,
.chroma .lnt,
.chroma .ln {
    color: #555;
    padding: 0;
    text-align: right;
    display: block;
    *display: inline; /* IE7 hack */
}

/* Line numbers column - fixed width */
.highlight .lntd:first-child {
    width: 4em;
    white-space: nowrap;
    text-align: right;
}

/* Code column */
.highlight .lntd:last-child {
    width: auto;
}

.highlight .lntd:last-child pre {
    padding-left: 0;
    white-space: pre;
}
{{- end }}

{{- if .Site.Params.legacyMode }}
/* clearfix utility */
.clearfix:after {
    content: ".";
    display: block;
    height: 0;
    clear: both;
    visibility: hidden;
}

.clearer {
    clear: both;
}
{{- end }}

/* editor
********************************************************************/
textarea, input[type="text"], input[type="password"] {
	background: transparent;
	color: #e5e3e8;
{{- if .Site.Params.legacyMode }}
    border: 1px solid #222038;
    padding: 0.25rem;
{{- else }}
	border: none;
	border-radius: .25rem;
	padding: .25rem;
{{- end }}
}

button, input[type="button"], input[type="submit"], select {
	background: #4e348a;
{{- if .Site.Params.legacyMode }}
    border: 1px solid #222038;
    color: #e5e3e8;
    padding: 0.25rem 0.5rem;
    cursor: pointer;
{{- else }}
	border: none;
	border-radius: .25rem;
	box-shadow: 1px 1px 3px #0d0b14;
	color: #e5e3e8;
	padding: .25rem .5rem;
	margin: 0 2px;
	transition: background-color .15s, box-shadow .15s;
{{- end }}
}

{{- if not .Site.Params.legacyMode }}
select {
	padding: .25rem .5rem !important;
}
{{- end }}

button:hover, input[type="button"]:hover, input[type="submit"]:hover, select:hover {
	background: #6a4eaa;
}

{{- if not .Site.Params.legacyMode }}
button:focus, input[type="button"]:focus, input[type="submit"]:focus, select:focus {
	background: #422d71;
	box-shadow: 0 0 0 transparent;
}

select:focus, select:target {
	background: transparent;
	color: #e5e3e8;
}

.nb-tool-bar button, input[type="button"] {
	border-radius: 0;
	margin: 0;
}

.nb-tool-bar button:first-child, input[type="button"]:first-child {
	border-radius: .25rem 0 0 .25rem;
}

.nb-tool-bar button:last-child, input[type="button"]:last-child {
	border-radius: 0 .25rem .25rem 0;
}

.section_highlight {
	background: transparent;
}


#nb-detail {
	background: transparent;
	min-height: 100vh;
}
{{- end }}

{{- if not .Site.Params.legacyMode }}
@media only screen and (min-width: 2200px) {
    #nb-header .nb-logo {
        overflow: hidden;
        display: flex;
        align-items: flex-end;
    }
    #nb-header .nb-logo img {
        width: 100%;
        min-width: 100%;
        height: auto;
        object-fit: unset;
        margin-top: unset;
    }
}
{{- end }}
