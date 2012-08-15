package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
)

var d = flag.String("d", "", "Some param")
var e = flag.String("e", "", "Some param")
var task_id = flag.String("id", "", "Task id")
var payload = flag.String("payload", "", "payload")

const queryURI = "http://search.twitter.com/search.%s?q=%s&rpp=%d"

// JSON Data Structure

type Payload struct {
	Query string `json:"query"`
}

type JTweets struct {
	Results     []Result `json:"results"`
	MaxId       float32 `json:"max_id"`
	SinceId     int     `json:"since_id"`
	RefreshURL  string  `json:"refresh_url"`
	NextPage    string  `json:"next_page"`
	Page        int     `json:"page"`
	CompletedIn float32 `json:"completed_in"`
	Query       string  `json:"query"`
}

type Result struct {
	ProfileImageUrl string `json:"profile_image_url"`
	CreatedAt       string `json:"created_at"`
	FromUser        string `json:"from_user"`
	Text            string `json:"text"`
	Id              float32 `json:"id"`
	FromUserId      int    `json:"from_user_id"`
	ISOLanguageCode string `json:"iso_language_code"`
	Source          string `json:"source"`
}

func ts(s string, n int) []string {
	r, err := http.Get(fmt.Sprintf(queryURI, "json", url.QueryEscape(s), n))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return nil
	}
	defer r.Body.Close()
	fmt.Fprintf(os.Stderr, "Searching for '%s' (%d results in %s)\n", s, n, "json")
	if r.StatusCode != http.StatusOK {
		fmt.Fprintf(os.Stderr, "Twitter is unable to search for %s as %s (%s)\n", s, "json", r.Status)
		return nil
	}
	return readjson(r.Body)
}

func readjson(r io.Reader) []string {
	b, err := ioutil.ReadAll(r)
	fmt.Println(string(b))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return nil
	}
	var twitter JTweets
	err = json.Unmarshal(b, &twitter)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Unable to parse the JSON feed:", err)
		return nil
	}

	twits := make([]string, len(twitter.Results))
	for i, result := range twitter.Results {
		fmt.Println(result.Text)
		twits[i] = result.Text
	}
	return twits
}

func main() {
	flag.Parse()
	file, err := ioutil.ReadFile(*payload)
	if err != nil {
		fmt.Fprintln(os.Stderr, "File error:", err)
		os.Exit(1)
	}
	fmt.Println("Payload:", string(file))
	var p Payload
	err = json.Unmarshal(file, &p)
	query := p.Query
	if err != nil {
		query = "iron.io"
	}
	twits := ts(query, 20)

	if len(twits) > 0 {
		fmt.Println("Writing to file:", twits[0])

		err := ioutil.WriteFile("sample_file.txt", []byte(twits[0]), 0644)
		if err != nil {
			fmt.Println("Error Writing to file:", err)
		}
	}
}
