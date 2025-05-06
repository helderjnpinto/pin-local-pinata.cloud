package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"
)

type FileEntry struct {
	Name string `json:"name"`
	CID  string `json:"cid"`
}

const (
	defaultAPIBase = "http://127.0.0.1:5001/api/v0"
	concurrency    = 5
	jsonlPath      = "all_files.jsonl"
)

var apiBase string

func init() {
	apiBase = os.Getenv("IPFS_API")
	if apiBase == "" {
		apiBase = defaultAPIBase
	}
}

func isPinned(cid string) bool {
	resp, err := http.Get(fmt.Sprintf("%s/pin/ls?arg=%s", apiBase, cid))
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == 200
}

func pinCID(cid string) error {
	resp, err := http.Post(fmt.Sprintf("%s/pin/add?arg=%s", apiBase, cid), "application/json", nil)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("pin failed: %s", string(body))
	}
	return nil
}

func worker(jobs <-chan FileEntry, wg *sync.WaitGroup, mutex *sync.Mutex) {
	defer wg.Done()
	for entry := range jobs {
		if isPinned(entry.CID) {
			mutex.Lock()
			fmt.Printf("✅ Already pinned: %s (%s)\n", entry.Name, entry.CID)
			mutex.Unlock()
			continue
		}
		err := pinCID(entry.CID)
		mutex.Lock()
		if err != nil {
			fmt.Printf("❌ Failed to pin: %s (%s) | Error: %v\n", entry.Name, entry.CID, err)
		} else {
			fmt.Printf("📌 Pinned: %s (%s)\n", entry.Name, entry.CID)
		}
		mutex.Unlock()
	}
}

func main() {
	file, err := os.Open(jsonlPath)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	jobs := make(chan FileEntry, concurrency)
	var wg sync.WaitGroup
	var mutex sync.Mutex

	for i := 0; i < concurrency; i++ {
		wg.Add(1)
		go worker(jobs, &wg, &mutex)
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		var entry FileEntry
		if err := json.Unmarshal(scanner.Bytes(), &entry); err == nil {
			jobs <- entry
		}
	}
	close(jobs)
	wg.Wait()

	fmt.Println("✅ Done.")
}
