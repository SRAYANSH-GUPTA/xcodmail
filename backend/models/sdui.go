package models

type ComponentType string

const (
	TypeColumn ComponentType = "column"
	TypeRow    ComponentType = "row"
	TypeText   ComponentType = "text"
	TypeImage  ComponentType = "image"
	TypeButton ComponentType = "button"
	TypeList   ComponentType = "list"
	TypeCard   ComponentType = "card"
	TypeInput  ComponentType = "input"
)

type Component struct {
	Type       ComponentType          `json:"type"`
	Properties map[string]interface{} `json:"properties,omitempty"`
	Children   []Component            `json:"children,omitempty"`
	Action     *Action                `json:"action,omitempty"`
}

type Action struct {
	Type string `json:"type"`
	Data string `json:"data,omitempty"`
}

type Screen struct {
	ID    string    `json:"id"`
	Title string    `json:"title"`
	Body  Component `json:"body"`
}
