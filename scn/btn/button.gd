tool
extends ColorRect
class_name SideBarButton

export (Texture) var button_texture : Texture setget set_button_texture
export (String) var button_name : String setget set_button_name

signal pressed()
signal hovered()
signal exited()

var colors : Dictionary = {"pressed":Color("#beac37"),"hovered":Color("#272737"),"exited":Color("#20202e")}
var pressed : bool = false setget set_pressed
var duration : float = 0.3

func set_button_texture(texture : Texture):
    button_texture = texture
    $ButtonContainer/TextureRect.set_texture(texture)

func set_button_name(b_name : String):
    button_name = b_name
    set_tooltip(b_name)
    $ButtonContainer/Label.set_text(b_name)

func _ready():
    _on_Button_mouse_exited()

func _on_Button_mouse_entered():
    if pressed : return
    $Tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,1), duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(self, "color", color, colors.hovered, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    emit_signal("hovered")

func _on_Button_mouse_exited():
    if pressed : return
    $Tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,0.4), duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.interpolate_property(self, "color", color, colors.exited, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    emit_signal("exited")

func _on_Button_gui_input(event):
    if event is InputEventMouseButton and event.is_pressed():
        press_button()

func press_button():
    $Tween.stop(self, "color")
    set_frame_color(colors.pressed)
    set_pressed(true)
    emit_signal("pressed")

func set_pressed(prssd : bool):
    pressed = prssd
    if not pressed: _on_Button_mouse_exited()
    else: if get_parent().get_parent(): get_parent().get_parent().focus_button(self)
