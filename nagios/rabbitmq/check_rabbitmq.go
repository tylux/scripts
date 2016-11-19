package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
)

func main() {
	username := flag.String("u", "guest", "-u RabbitMQ Username")
	password := flag.String("p", "guest", "-p RabbitMQ Password")
	rabbitHost := flag.String("H", "localhost", "-H RabbitMQ Host")
	port := flag.String("P", "15672", "-P RabbitMQ Port, defaults to 15672")
	flag.Parse()
	checkAliveness(*username, *password, *port, *rabbitHost)
}

func checkAliveness(username, password, port, rabbitHost string) {
	// Declares a test queue, then publishes and consumes a message.
	//Intended for use by monitoring tools. If everything is working correctly, will return HTTP status 200 with body
	urlBuild := fmt.Sprintf("http://%s:%s@%s:%s/api/aliveness-test/", username, password, rabbitHost, port)

	resp, err := http.Get(urlBuild + "%2F")

	if err != nil {
		fmt.Printf("Critical: %s", err)
		os.Exit(1)
	}

	status := (resp.StatusCode)
	body := (resp.Body)

	if status == 200 {
		fmt.Printf("OK: %d Response Code\n", status)
		os.Exit(0)
	} else if status != 200 {
		fmt.Printf("WARNING: %d Response Code\n", status)
		os.Exit(1)
	} else {
		fmt.Printf("UNKOWNN: %d - %s\n ", status, body)
		os.Exit(2)
	}
	defer resp.Body.Close()
}
