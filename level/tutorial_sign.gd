class_name TutorialSign
extends Node2D

# Affiche de tutoriel scotchee au mur : purement decorative, le texte est regle par niveau

@export_multiline var text := "":
	set(value):
		text = value
		if is_node_ready():
			_label.text = value

@onready var _label: Label = $Feuille/Texte


func _ready() -> void:
	_label.text = text
