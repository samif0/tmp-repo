package main

import (
	"log"
	"os"
	"time"

	"github.com/blackflow/auth/handlers"
	"github.com/gin-gonic/gin"
)

func main() {
	// TODO: figure out what release mode does in gin
	env := os.Getenv("GIN_MODE")
	if env == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().Format(time.RFC3339),
		})
	})

	api := r.Group("/api")
	{
		api.GET("/auth", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message":   "auth root",
				"timestamp": time.Now().Format(time.RFC3339),
			})
		})

		users := api.Group("/user")
		{
			users.GET("/", handlers.GetUsers)
		}
	}

	r.NoRoute(func(c *gin.Context) {
		c.JSON(404, gin.H{
			"error": "Not Found",
			"path":  c.Request.URL.Path,
		})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Service running on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
