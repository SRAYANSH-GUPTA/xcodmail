package main

import (
	"coldmail-backend/handlers"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/api/screen/:id", handlers.GetScreen)

	r.Run(":8080")
}
