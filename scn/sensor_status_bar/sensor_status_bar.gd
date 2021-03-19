extends HBoxContainer
class_name Sensor

onready var topic_lbl : Label = $Topic
onready var name_lbl : Label = $Name
onready var value_lbl : Label = $Status/Value
onready var status : HBoxContainer = $Status

var status_colors : Dictionary = {
    "offline":Color("#767676"),
    "online":Color("#00ff76"),
    "disconnected":Color("#ff0048")
}

var color : Color
var value : String
var topic : String setget set_topic

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func set_status(status_code : int):
    match status_code:
        0:
            value = "Online"
            color = status_colors.online
        -1:
            value = "Offline"
            color = status_colors.offline
        _:
            value = "Disconnected"
            color = status_colors.disconnected
    value_lbl.set_text(value)
    status.set_modulate(color)

func setup_sensor(n : String, t : String, s : int = -1):
    set_name(n)
    name_lbl.set_text(n)
    set_topic(t)
    set_status(s)

func set_topic(t : String):
    topic = t
    topic_lbl.set_text(topic)

var i : float = 0

func _process(delta):
    if value == "Online":
        i += delta*2.5
        var sin_value : float = sin(i)
        status.set_modulate(status_colors.offline.linear_interpolate(status_colors.online, abs(sin_value)))
        if i >= 50: i = 0




