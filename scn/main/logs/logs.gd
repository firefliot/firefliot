extends PanelContainer

func _ready() -> void:
    LOGGER.connect("log_line", self, "_on_new_line")

func _on_new_line(line : String):
    $DockContainer/RichTextLabel.append_bbcode(line+"\n")
