package main

import (
	"fmt"
	"net/http"
)

type FullName func(string, string) string
type User struct {
	firstName string
	lastName  string
	fullName  FullName
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		user := User{
			firstName: "tung",
			lastName:  "nguyen",
			fullName: func(first string, last string) string {
				return first + last
			},
		}
		fmt.Fprintf(w, user.fullName("tung", "nguyen"))
	})

	fs := http.FileServer(http.Dir("static/"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	http.ListenAndServe(":9000", nil)
}
