package handlers

import (
	"coldmail-backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetScreen(c *gin.Context) {
	screenID := c.Param("id")

	var screen models.Screen

	switch screenID {
	case "home":
		screen = getHomeScreen()
	case "email_send":
		screen = getEmailSendScreen()
	case "pdf_upload":
		screen = getPdfUploadScreen()
	case "templates":
		screen = getTemplatesScreen()
	default:
		c.JSON(http.StatusNotFound, gin.H{"error": "Screen not found"})
		return
	}

	c.JSON(http.StatusOK, screen)
}

func getHomeScreen() models.Screen {
	return models.Screen{
		ID:    "home",
		Title: "ColdMail Home",
		Body: models.Component{
			Type: models.TypeColumn,
			Children: []models.Component{
				{
					Type: models.TypeText,
					Properties: map[string]interface{}{
						"text":  "Welcome to ColdMail",
						"style": "headline",
					},
				},
				{
					Type: models.TypeButton,
					Properties: map[string]interface{}{
						"label": "Send Email",
					},
					Action: &models.Action{
						Type: "navigate",
						Data: "/email_send",
					},
				},
				{
					Type: models.TypeButton,
					Properties: map[string]interface{}{
						"label": "Upload PDF",
					},
					Action: &models.Action{
						Type: "navigate",
						Data: "/pdf_upload",
					},
				},
				{
					Type: models.TypeButton,
					Properties: map[string]interface{}{
						"label": "Templates",
					},
					Action: &models.Action{
						Type: "navigate",
						Data: "/templates",
					},
				},
			},
		},
	}
}

func getEmailSendScreen() models.Screen {
	return models.Screen{
		ID:    "email_send",
		Title: "Send Email",
		Body: models.Component{
			Type: models.TypeColumn,
			Children: []models.Component{
				{
					Type: models.TypeInput,
					Properties: map[string]interface{}{
						"hint": "Recipient Email",
					},
				},
				{
					Type: models.TypeInput,
					Properties: map[string]interface{}{
						"hint": "Subject",
					},
				},
				{
					Type: models.TypeInput,
					Properties: map[string]interface{}{
						"hint": "Body",
						"lines": 5,
					},
				},
				{
					Type: models.TypeButton,
					Properties: map[string]interface{}{
						"label": "Send",
					},
					Action: &models.Action{
						Type: "api_call",
						Data: "/api/send",
					},
				},
			},
		},
	}
}

func getPdfUploadScreen() models.Screen {
	return models.Screen{
		ID:    "pdf_upload",
		Title: "Upload PDF",
		Body: models.Component{
			Type: models.TypeColumn,
			Children: []models.Component{
				{
					Type: models.TypeText,
					Properties: map[string]interface{}{
						"text": "Select a PDF to upload",
					},
				},
				{
					Type: models.TypeButton,
					Properties: map[string]interface{}{
						"label": "Choose File",
					},
					Action: &models.Action{
						Type: "pick_file",
					},
				},
			},
		},
	}
}

func getTemplatesScreen() models.Screen {
	return models.Screen{
		ID:    "templates",
		Title: "Email Templates",
		Body: models.Component{
			Type: models.TypeList,
			Children: []models.Component{
				{
					Type: models.TypeCard,
					Children: []models.Component{
						{
							Type: models.TypeText,
							Properties: map[string]interface{}{
								"text": "Welcome Email",
								"style": "subtitle",
							},
						},
						{
							Type: models.TypeText,
							Properties: map[string]interface{}{
								"text": "Hi [Name], welcome to...",
							},
						},
					},
				},
				{
					Type: models.TypeCard,
					Children: []models.Component{
						{
							Type: models.TypeText,
							Properties: map[string]interface{}{
								"text": "Follow Up",
								"style": "subtitle",
							},
						},
						{
							Type: models.TypeText,
							Properties: map[string]interface{}{
								"text": "Just checking in...",
							},
						},
					},
				},
			},
		},
	}
}
