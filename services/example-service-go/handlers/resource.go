package handlers

import (
	"math/rand"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// Resource represents a resource in our API
type Resource struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

// GetResources returns all resources
func GetResources(c *gin.Context) {
	// TODO: Implement database retrieval logic
	resources := []Resource{
		{ID: 1, Name: "Resource 1"},
		{ID: 2, Name: "Resource 2"},
	}

	c.JSON(http.StatusOK, gin.H{
		"data": resources,
	})
}

// GetResourceByID returns a specific resource by ID
func GetResourceByID(c *gin.Context) {
	// Get ID from URL parameter
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	// TODO: Implement database retrieval logic for specific resource
	resource := Resource{ID: id, Name: "Resource " + idStr}

	c.JSON(http.StatusOK, resource)
}

// CreateResource creates a new resource
func CreateResource(c *gin.Context) {
	var newResource Resource

	// Bind JSON body to resource struct
	if err := c.ShouldBindJSON(&newResource); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Implement validation
	// TODO: Implement database creation logic
	newResource.ID = rand.Intn(1000)

	c.JSON(http.StatusCreated, newResource)
}

// UpdateResource updates an existing resource
func UpdateResource(c *gin.Context) {
	// Get ID from URL parameter
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	var updatedResource Resource

	// Bind JSON body to resource struct
	if err := c.ShouldBindJSON(&updatedResource); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Implement validation
	// TODO: Implement database update logic
	updatedResource.ID = id

	c.JSON(http.StatusOK, gin.H{
		"id":      id,
		"name":    updatedResource.Name,
		"updated": true,
	})
}

// DeleteResource deletes a resource
func DeleteResource(c *gin.Context) {
	// Get ID from URL parameter
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	// TODO: Implement database deletion logic
	c.JSON(http.StatusOK, gin.H{"deleted": id})
}