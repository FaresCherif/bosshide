class_name QuizQuestions
extends RefCounted

# Questions posees par le collegue : 3 choix, "answer" est l'indice du bon choix
const QUESTIONS := [
	{"text": "What does ASAP mean?",
		"choices": ["As soon as possible", "Always skip all procedures", "Ask someone and pray"], "answer": 0},
	{"text": "What does FYI mean in an email?",
		"choices": ["Fix your issue", "For your information", "Forward yesterday's invoice"], "answer": 1},
	{"text": "What does EOD mean?",
		"choices": ["Email on demand", "Every other day", "End of day"], "answer": 2},
	{"text": "Your status says OOO. What does it mean?",
		"choices": ["Out of office", "Only on Mondays", "Out of order"], "answer": 0},
	{"text": "What does CC mean in an email?",
		"choices": ["Coffee cup", "Carbon copy", "Call center"], "answer": 1},
	{"text": "Which shortcut copies text?",
		"choices": ["Ctrl+V", "Ctrl+Z", "Ctrl+C"], "answer": 2},
	{"text": "Which shortcut undoes your last action?",
		"choices": ["Ctrl+Z", "Ctrl+X", "Ctrl+S"], "answer": 0},
	{"text": "How many hours are in a 9-to-5 workday?",
		"choices": ["9", "8", "5"], "answer": 1},
]
