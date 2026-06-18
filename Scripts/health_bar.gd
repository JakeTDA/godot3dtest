extends ProgressBar


func _ready():
	# Create a brand new style for the FILL (the colored progress)
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color.GREEN  # < Change GREEN to RED, BLUE, etc.
	add_theme_stylebox_override("fill", fill_style)

	# Create a brand new style for the BACKGROUND
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color.DARK_GRAY # < Background color
	add_theme_stylebox_override("background", bg_style)
