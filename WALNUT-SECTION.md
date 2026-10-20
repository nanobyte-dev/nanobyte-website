# Walnut section: placement notes

The articles live in `content/walnut/` and are self-contained: `_index.md` (project page) and four articles with `weight` 1 to 4. All of them are `draft: true`. Nothing outside `content/walnut/` was changed. Two paths from here, depending on where Walnut ends up.

## If it goes on nanobyte.dev

### 1. Sidebar: `themes/nanobyte/layouts/partials/sidebar.html`

Add a block after the "Transcripts" `<li>` and before `<li><a href="/sitemap/">All Articles</a></li>`. It follows the same pattern as the other sections, plus the draft filter and weight order:

```html
                <!-- Walnut section -->
                <li>
                    <a href="/walnut/" {{ if eq $.RelPermalink "/walnut/" }}class="active"{{ end }}>Walnut (PS3 Linux)</a>
                    {{ $walnut := .Site.GetPage "/walnut" }}
                    {{ if or (eq .Section "walnut") (eq .CurrentSection $walnut) }}
                    <ul>
                        {{ range $walnut.Pages.ByWeight }}
                        {{ if not .Params.draft }}
                        <li><a href="{{ .RelPermalink }}" {{ if eq $.RelPermalink .RelPermalink }}class="active"{{ end }}>{{ .Title }}</a></li>
                        {{ end }}
                        {{ end }}
                    </ul>
                    {{ end }}
                </li>
```

Note: `.Params.draft` is true for every page of the section until you flip the flag, so the sub-list stays empty in a `--buildDrafts` preview too. If you want to preview the sub-list before publishing, drop the `{{ if not .Params.draft }}` pair while testing. (Hugo's own `--buildDrafts` already keeps drafts out of production, so the template filter is only a second line of defence; the Transcripts block has the same filter.)

### 2. Main menu: all three configs

The header menu is read from `[[menu.main]]`. Add the same entry to each file after Blog (weight 2). Weights are integers, so Search, YouTube and Discord move up by one:

```toml
[[menu.main]]
  name = "Walnut"
  url = "/walnut/"
  weight = 3
```

- `config.toml`: has the full menu (Home, Blog, Search, YouTube, Discord). Add the entry and shift Search to 4, YouTube to 5, Discord to 6.
- `config-legacy.toml`: the same menu, same change.
- `hugo.toml`: today this is the stub from `hugo new site` (three lines, no menu, `baseURL = 'https://example.org/'`). It is not used by `run-local.sh` or `build.sh`, which pass `--config` explicitly. Nothing to add unless you start using it, in which case the whole menu would have to be copied in first. Be aware that a bare `hugo` call in this directory picks `hugo.toml` before `config.toml`.

### 3. Things that only show up after you flip `draft: false`

- `themes/nanobyte/layouts/_default/list.html` lists `.Pages` and hides any page with `draft: true`. The section page `/walnut/` has the articles linked by hand in `_index.md`, so it reads fine either way, but the auto-generated "Articles in this section" list is empty until the articles are published.
- `content/sitemap.md` and `content/building-an-os/_index.md` link their pages by hand. If you want Walnut on the sitemap, add four lines there.
- Dates are set to 2026-10-21 in front matter. Hugo treats a future date as unpublished (`buildFuture` is off), so pick a date that is not in the future on the day you publish.

## If it goes on its own site (walnut.nanobyte.dev)

Copy `content/walnut/` to the new site's `content/` (or promote `_index.md` to be its home page and move the articles to `content/`; the links in `_index.md` and the articles use `/walnut/...` and would need that prefix removed). It needs the same theme for the shortcodes (`code`, `wip`) and the ` ```dot ` diagram preprocessing (`preprocess_diagrams.py`, `diagram_config.yml`, `build.sh` step 1). No images are used yet.

## Notes for review

- Public name rules: "Walnut" is the distribution; "PS3"/"PlayStation 3" appear only as the hardware name. Driver and tool names (`ps3rsx`, `ps3fb`, `ps3vswap0`, `ps3-waker`) are the actual module names in the code, so they stay unless you rename them in the code.
- Every `{{< wip >}}` box is a note to you, not reader text. Remove them before publishing.
- No images. Suggested photos are named in the wip boxes (Petitboot menu, a text console next to the desktop, a black screen after a wedge).
