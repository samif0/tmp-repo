package main

import (
	"log"
	"os"
	"time"

	"github.com/blackflow/example-service/handlers"
	"github.com/gin-gonic/gin"
)

func main() {
	// Set Gin mode based on environment
	env := os.Getenv("GIN_MODE")
	if env == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Create router
	r := gin.Default()

	// Health check endpoint for container monitoring
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().Format(time.RFC3339),
		})
	})

	// API routes
	api := r.Group("/api/v1")
	{
		// Basic example endpoint
		api.GET("/example", func(c *gin.Context) {
			c.JSON(200, gin.H{
				"message":   "Example API response",
				"timestamp": time.Now().Format(time.RFC3339),
			})
		})

		// Resource endpoints
		resources := api.Group("/resource")
		{
			resources.GET("/", handlers.GetResources)
			resources.GET("/:id", handlers.GetResourceByID)
			resources.POST("/", handlers.CreateResource)
			resources.PUT("/:id", handlers.UpdateResource)
			resources.DELETE("/:id", handlers.DeleteResource)
		}
	}

	// 404 handler for undefined routes
	r.NoRoute(func(c *gin.Context) {
		c.JSON(404, gin.H{
			"error": "Not Found",
			"path":  c.Request.URL.Path,
		})
	})

	// Start the server
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Service running on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}