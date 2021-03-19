extends PanelContainer
class_name SideBar

onready var selected_bar : ColorRect = $SelectedBar
onready var tween : Tween = $Tween

var buttons : Array = []

signal button_pressed(btn_index, btn_name)

# Called when the node enters the scene tree for the first time.
func _ready():
    selected_bar.hide()
    for btn_index in $ButtonContainer.get_children().size(): 
        $ButtonContainer.get_children()[btn_index].connect("pressed", self, "_on_button_pressed", [btn_index, $ButtonContainer.get_child(btn_index).name])
        buttons.append($ButtonContainer.get_child(btn_index))

func press_button(button : SideBarButton):
    button._on_Button_mouse_entered()
    button.press_button()

func _on_button_pressed(btn_index : int, btn_name : String):
    emit_signal("button_pressed", btn_index, btn_name)

# Automatically called by buttons
func focus_button(button : SideBarButton):
    for btn in $ButtonContainer.get_children(): if btn != button: btn.pressed = false 
    selected_bar.show()
    tween.interpolate_property(selected_bar, "rect_position", selected_bar.rect_position, button.rect_position, 0.15, Tween.TRANS_QUAD, Tween.EASE_OUT)
    tween.start()
