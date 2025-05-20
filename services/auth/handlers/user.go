package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type User struct {
	UserId int    `json:"id"`
	Name   string `json:"name"`
}

func GetUsers(c *gin.Context) {
	user := []User{
		{UserId: 1, Name: "user-name-1"},
	}

	c.JSON(http.StatusOK, gin.H{
		"data": user,
	})
}
