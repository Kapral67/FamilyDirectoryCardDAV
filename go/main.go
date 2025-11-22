package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"time"
)

type UpstreamRequest struct {
	Method  string            `json:"method"`
	Path    string            `json:"path"`
	Headers map[string]string `json:"headers"`
	Body    string            `json:"body"`
}

type UpstreamResponse struct {
	Status  int               `json:"status"`
	Headers map[string]string `json:"headers"`
	Body    string            `json:"body"`
}

func main() {
	sock := "/run/carddav/proxy.sock"
	_ = os.Remove(sock)

	ln, err := net.Listen("unix", sock)
	if err != nil {
		log.Fatalf("listen sock: %v", err)
	}

	client := &http.Client{
		Timeout: 25 * time.Second, // keep below nginx & APIGW timeouts
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleProxy(w, r, client)
	})

	log.Fatal(http.Serve(ln, nil))
}

func handleProxy(w http.ResponseWriter, r *http.Request, client *http.Client) {
	isHead := r.Method == http.MethodHead

	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "failed to read request body", http.StatusBadGateway)
		return
	}
	defer r.Body.Close()

	headers := make(map[string]string, len(r.Header))
	for name, values := range r.Header {
		if len(values) > 0 {
			headers[name] = values[0]
		}
	}

	apiEndpoint := r.Header.Get("X-Api-Endpoint")
	if apiEndpoint == "" {
		http.Error(w, "No Upstream", http.StatusBadGateway)
		return
	}
	delete(headers, "X-Api-Endpoint")

	upReq := UpstreamRequest{
		Method:  r.Method,
		Path:    r.URL.Path,
		Headers: headers,
		Body:    string(bodyBytes),
	}

	payload, err := json.Marshal(upReq)
	if err != nil {
		http.Error(w, "failed to encode upstream request", http.StatusBadGateway)
		return
	}

	upstream := "https://" + apiEndpoint
	upHTTPReq, err := http.NewRequest("POST", upstream, bytes.NewReader(payload))
	if err != nil {
		http.Error(w, "failed to build upstream request", http.StatusBadGateway)
		return
	}
	upHTTPReq.Header.Set("Content-Type", "application/json")

	if auth, ok := headers["Authorization"]; ok {
		upHTTPReq.Header.Set("Authorization", auth)
	}

	upResp, err := client.Do(upHTTPReq)
	if err != nil {
		http.Error(w, "upstream error", http.StatusBadGateway)
		return
	}
	defer upResp.Body.Close()

	// Case 1: API Gateway status != 200 → proxy as-is
	if upResp.StatusCode != http.StatusOK {
		copyHeadersExcludingHopByHop(w.Header(), upResp.Header)

		if upResp.StatusCode == http.StatusUnauthorized {
			w.Header().Set("WWW-Authenticate", `Basic realm="CardDAV"`)
		}

		w.WriteHeader(upResp.StatusCode)
		_, _ = io.Copy(w, upResp.Body)
		return
	}

	// Case 2: API Gateway status == 200 → expect JSON envelope
	var upBodyBuf bytes.Buffer
	if _, err := io.Copy(&upBodyBuf, upResp.Body); err != nil {
		http.Error(w, "failed to read upstream body", http.StatusBadGateway)
		return
	}

	var upJSON UpstreamResponse
	if err := json.Unmarshal(upBodyBuf.Bytes(), &upJSON); err != nil {
		log.Printf("invalid upstream JSON: %v; body: %s", err, upBodyBuf.String())
		http.Error(w, "invalid upstream JSON", http.StatusBadGateway)
		return
	}

	for k, v := range upJSON.Headers {
		ck := http.CanonicalHeaderKey(k)
		switch ck {
		case "Connection", "Keep-Alive", "Proxy-Authenticate", "Proxy-Authorization", "Te", "Trailer", "Transfer-Encoding", "Upgrade":
			continue
		case "Content-Length":
			// For HEAD, we want to preserve upstream Content-Length.
			// For others, let Go compute it from the body we write.
			if !isHead {
				continue
			}
		}
		w.Header().Set(k, v)
	}

	if upJSON.Status == http.StatusUnauthorized {
		w.Header().Set("WWW-Authenticate", `Basic realm="CardDAV"`)
	}

	w.WriteHeader(upJSON.Status)

	_, _ = w.Write([]byte(upJSON.Body))
}

func copyHeadersExcludingHopByHop(dst http.Header, src http.Header) {
	for k, values := range src {
		ck := http.CanonicalHeaderKey(k)
		switch ck {
		case "Connection", "Keep-Alive", "Proxy-Authenticate", "Proxy-Authorization", "Te", "Trailer", "Transfer-Encoding", "Upgrade", "Content-Length":
			continue
		}
		for _, v := range values {
			dst.Add(k, v)
		}
	}
}
