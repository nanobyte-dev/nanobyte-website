package main

import (
	"encoding/json"
	"encoding/xml"
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/blevesearch/bleve/v2"
	"github.com/blevesearch/bleve/v2/search/query"
)

type SearchIndex struct {
	Pages []Page `json:"pages"`
}

type Page struct {
	Title   string `json:"title"`
	URL     string `json:"url"`
	Content string `json:"content"`
	Section string `json:"section"`
}

type YouTubeRSS struct {
	XMLName xml.Name       `xml:"http://www.w3.org/2005/Atom feed"`
	Entries []YouTubeEntry `xml:"entry"`
}

type YouTubeEntry struct {
	Title     string `xml:"title"`
	Link      struct {
		Href string `xml:"href,attr"`
		Rel  string `xml:"rel,attr"`
	} `xml:"link"`
	VideoID   string    `xml:"http://www.youtube.com/xml/schemas/2015 videoId"`
	Published time.Time `xml:"published"`
}

type Video struct {
	Title     string
	URL       string
	Thumbnail string
	Published time.Time
}

var (
	searchIndex SearchIndex
	bleveIndex bleve.Index
	cachedVideos []Video
	lastVideoFetch time.Time
	templates *template.Template
	searchPageTemplate string
)

const (
	youtubeChannelID = "UCSPIuWADJIMIf9Erf--XAsA" // nanobyte-dev channel ID
	youtubeRSSURL = "https://www.youtube.com/feeds/videos.xml?channel_id=" + youtubeChannelID
	videoCacheDuration = 1 * time.Hour
)

func main() {
	// Load templates
	var err error
	templates, err = template.ParseGlob("templates/*.html")
	if err != nil {
		log.Fatal("Error loading templates:", err)
	}

	// Load Hugo-generated search page template
	if err := loadSearchPageTemplate(); err != nil {
		log.Fatal("Error loading search page template:", err)
	}

	// Load and index search data
	if err := loadAndIndexSearchData(); err != nil {
		log.Fatal("Error loading search index:", err)
	}

	// HTTP handlers
	http.HandleFunc("/search", handleSearch)
	http.HandleFunc("/api/latest-videos", handleLatestVideos)
	http.HandleFunc("/health", handleHealth)

	log.Println("Go server starting on :3000")
	log.Fatal(http.ListenAndServe(":3000", nil))
}

func loadSearchPageTemplate() error {
	data, err := os.ReadFile("/app/search-template.html")
	if err != nil {
		return err
	}
	searchPageTemplate = string(data)
	return nil
}

func loadAndIndexSearchData() error {
	// Load JSON data
	file, err := os.ReadFile("/app/search-index.json")
	if err != nil {
		return err
	}

	if err := json.Unmarshal(file, &searchIndex); err != nil {
		return err
	}

	// Create Bleve index in memory
	mapping := bleve.NewIndexMapping()

	// Configure title to have higher weight
	titleFieldMapping := bleve.NewTextFieldMapping()
	titleFieldMapping.Analyzer = "en"

	contentFieldMapping := bleve.NewTextFieldMapping()
	contentFieldMapping.Analyzer = "en"

	docMapping := bleve.NewDocumentMapping()
	docMapping.AddFieldMappingsAt("title", titleFieldMapping)
	docMapping.AddFieldMappingsAt("content", contentFieldMapping)

	mapping.AddDocumentMapping("page", docMapping)

	bleveIndex, err = bleve.NewMemOnly(mapping)
	if err != nil {
		return err
	}

	// Index all pages
	for i, page := range searchIndex.Pages {
		if err := bleveIndex.Index(fmt.Sprintf("page_%d", i), page); err != nil {
			return err
		}
	}

	log.Printf("Indexed %d pages", len(searchIndex.Pages))
	return nil
}

// bleveSearch performs full-text search using Bleve
func bleveSearch(queryStr string) []Page {
	// Create a boosted query for title
	titleQuery := query.NewMatchQuery(queryStr)
	titleQuery.SetField("title")
	titleQuery.SetBoost(10.0) // Title matches score 10x higher

	// Create a query for content
	contentQuery := query.NewMatchQuery(queryStr)
	contentQuery.SetField("content")

	// Create fuzzy query for typo tolerance
	fuzzyQuery := query.NewFuzzyQuery(queryStr)

	// Combine with disjunction (OR) - at least one must match
	combinedQuery := query.NewDisjunctionQuery([]query.Query{
		titleQuery,
		contentQuery,
		fuzzyQuery,
	})
	combinedQuery.SetMin(1)

	searchRequest := bleve.NewSearchRequest(combinedQuery)
	searchRequest.Size = 100 // Return up to 100 results
	searchRequest.Fields = []string{"*"}

	searchResults, err := bleveIndex.Search(searchRequest)
	if err != nil {
		log.Printf("Search error: %v", err)
		return nil
	}

	// Convert results back to Pages
	var results []Page
	for _, hit := range searchResults.Hits {
		// Find the original page by matching URL or title
		for _, page := range searchIndex.Pages {
			if page.URL == hit.Fields["url"] || page.Title == hit.Fields["title"] {
				results = append(results, page)
				break
			}
		}
	}

	return results
}

func handleSearch(w http.ResponseWriter, r *http.Request) {
	query := strings.TrimSpace(r.URL.Query().Get("q"))

	var results []Page
	if query != "" {
		results = bleveSearch(query)
	}

	// Generate results HTML
	var resultsHTML string
	if query == "" {
		resultsHTML = `<div class="empty-state" style="text-align: center; padding: 2rem; color: #999;">
			<p>Enter a search query above to find tutorials, posts, and resources.</p>
		</div>`
	} else if len(results) == 0 {
		resultsHTML = `<div class="no-results" style="text-align: center; padding: 2rem; color: #999;">
			<p>No results found for "` + template.HTMLEscapeString(query) + `"</p>
			<p>Try different keywords or check your spelling.</p>
		</div>`
	} else {
		resultsHTML = `<div class="results-info" style="margin-bottom: 1rem; color: #999;">
			Found ` + fmt.Sprintf("%d", len(results)) + ` result`
		if len(results) != 1 {
			resultsHTML += "s"
		}
		resultsHTML += ` for "` + template.HTMLEscapeString(query) + `"
		</div>`

		for _, result := range results {
			// Find and highlight the search term in context
			excerpt := extractSearchContext(result.Content, query, 200)

			resultsHTML += `<div class="result" style="margin-bottom: 1.5rem; padding: 1rem; background: rgba(255,255,255,0.03); border-radius: 4px;">
				<h2 style="margin-top: 0;"><a href="` + template.HTMLEscapeString(result.URL) + `">` + template.HTMLEscapeString(result.Title) + `</a></h2>`

			if result.Section != "" {
				resultsHTML += `<div class="result-section" style="color: #999; font-size: 0.9em; margin-bottom: 0.5rem; text-transform: capitalize;">` + template.HTMLEscapeString(result.Section) + `</div>`
			}

			resultsHTML += `<div class="result-excerpt" style="color: #ccc;">` + excerpt + `</div>
			</div>`
		}
	}

	// Replace placeholders in template
	page := searchPageTemplate
	page = strings.ReplaceAll(page, "__SEARCH_QUERY__", template.HTMLEscapeString(query))
	page = strings.ReplaceAll(page, "__SEARCH_RESULTS__", resultsHTML)

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Write([]byte(page))
}

// extractSearchContext finds the search query in content and returns highlighted excerpt
func extractSearchContext(content, query string, contextLen int) string {
	contentLower := strings.ToLower(content)
	queryLower := strings.ToLower(query)

	// Find the first occurrence of the query
	index := strings.Index(contentLower, queryLower)

	if index == -1 {
		// Query not found in content (shouldn't happen, but fallback)
		if len(content) > contextLen {
			return template.HTMLEscapeString(content[:contextLen]) + "..."
		}
		return template.HTMLEscapeString(content)
	}

	// Calculate context window
	start := index - contextLen/2
	if start < 0 {
		start = 0
	}

	end := index + len(query) + contextLen/2
	if end > len(content) {
		end = len(content)
	}

	// Adjust to word boundaries
	if start > 0 {
		// Find the next space after start
		for start < len(content) && content[start] != ' ' {
			start++
		}
		start++ // Skip the space
	}

	if end < len(content) {
		// Find the previous space before end
		for end > start && content[end] != ' ' {
			end--
		}
	}

	excerpt := content[start:end]

	// Build the highlighted excerpt
	var result strings.Builder
	if start > 0 {
		result.WriteString("...")
	}

	// Replace all occurrences of query with highlighted version (case-insensitive)
	excerptLower := strings.ToLower(excerpt)
	lastPos := 0

	for {
		pos := strings.Index(excerptLower[lastPos:], queryLower)
		if pos == -1 {
			break
		}
		pos += lastPos

		// Add text before match (escaped)
		result.WriteString(template.HTMLEscapeString(excerpt[lastPos:pos]))

		// Add highlighted match
		result.WriteString(`<mark style="background: #F0A9B8; color: #000; padding: 0 2px; border-radius: 2px;">`)
		result.WriteString(template.HTMLEscapeString(excerpt[pos : pos+len(query)]))
		result.WriteString(`</mark>`)

		lastPos = pos + len(query)
	}

	// Add remaining text (escaped)
	result.WriteString(template.HTMLEscapeString(excerpt[lastPos:]))

	if end < len(content) {
		result.WriteString("...")
	}

	return result.String()
}

func handleLatestVideos(w http.ResponseWriter, r *http.Request) {
	// Check cache
	if time.Since(lastVideoFetch) > videoCacheDuration || len(cachedVideos) == 0 {
		videos, err := fetchLatestVideos()
		if err != nil {
			log.Printf("Error fetching videos: %v", err)
			// Return empty videos list instead of error
			cachedVideos = []Video{}
			lastVideoFetch = time.Now()
		} else {
			cachedVideos = videos
			lastVideoFetch = time.Now()
		}
	}

	// Limit to 6 most recent videos
	videos := cachedVideos
	if len(videos) > 6 {
		videos = videos[:6]
	}

	data := struct {
		Videos []Video
	}{
		Videos: videos,
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := templates.ExecuteTemplate(w, "videos.html", data); err != nil {
		log.Printf("Error rendering videos template: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
	}
}

func fetchLatestVideos() ([]Video, error) {
	resp, err := http.Get(youtubeRSSURL)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var feed YouTubeRSS
	if err := xml.Unmarshal(body, &feed); err != nil {
		return nil, err
	}

	videos := make([]Video, 0, len(feed.Entries))
	for _, entry := range feed.Entries {
		videos = append(videos, Video{
			Title:     entry.Title,
			URL:       entry.Link.Href,
			Thumbnail: "https://i.ytimg.com/vi/" + entry.VideoID + "/mqdefault.jpg",
			Published: entry.Published,
		})
	}

	return videos, nil
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	w.Write([]byte("healthy"))
}
