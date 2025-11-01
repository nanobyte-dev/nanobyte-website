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

	// Load search index
	if err := loadSearchIndex(); err != nil {
		log.Printf("Warning: Could not load search index: %v", err)
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

func loadSearchIndex() error {
	file, err := os.Open("/app/search-index.json")
	if err != nil {
		return err
	}
	defer file.Close()

	decoder := json.NewDecoder(file)
	return decoder.Decode(&searchIndex)
}

func handleSearch(w http.ResponseWriter, r *http.Request) {
	query := strings.TrimSpace(r.URL.Query().Get("q"))

	var results []Page
	if query != "" {
		queryLower := strings.ToLower(query)
		for _, page := range searchIndex.Pages {
			if strings.Contains(strings.ToLower(page.Title), queryLower) ||
			   strings.Contains(strings.ToLower(page.Content), queryLower) {
				results = append(results, page)
			}
		}
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
			excerpt := result.Content
			if len(excerpt) > 300 {
				excerpt = excerpt[:300] + "..."
			}

			resultsHTML += `<div class="result" style="margin-bottom: 1.5rem; padding: 1rem; background: rgba(255,255,255,0.03); border-radius: 4px;">
				<h2 style="margin-top: 0;"><a href="` + template.HTMLEscapeString(result.URL) + `">` + template.HTMLEscapeString(result.Title) + `</a></h2>`

			if result.Section != "" {
				resultsHTML += `<div class="result-section" style="color: #999; font-size: 0.9em; margin-bottom: 0.5rem; text-transform: capitalize;">` + template.HTMLEscapeString(result.Section) + `</div>`
			}

			resultsHTML += `<div class="result-excerpt" style="color: #ccc;">` + template.HTMLEscapeString(excerpt) + `</div>
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
