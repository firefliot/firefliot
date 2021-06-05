extends PanelContainer

var sensor_status_bar_scene : PackedScene = preload("res://scn/sensor_status_bar/sensor_status_bar.tscn")

onready var sensors_container : VBoxContainer = $DockContainer/SensorsContainer

var root : TreeItem


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

func update_status(datetime : Dictionary, topic : String, payload : String) -> void:
    var p_array : Array = payload.split(",")
    var sensor_id : String = p_array[0]
    var status : String = p_array[1]
    if not has_sensor(sensor_id):
        var sensor : Sensor = add_sensor(topic, sensor_id)
    get_sensor(sensor_id).set_status(int(status))

func update_battery(topic : String, sensor_id : String, batt : float) -> void:
    if not has_sensor(sensor_id):
        var sensor : Sensor = add_sensor(topic, sensor_id)
    get_sensor(sensor_id).set_battery(batt)    

func add_sensor(topic : String, sensor_id : String) -> Sensor:
    var sensor : Sensor = sensor_status_bar_scene.instance()
    sensors_container.add_child(sensor)
    sensor.setup(sensor_id, topic)
    return sensor

func get_sensor(sensor_id : String) -> Sensor:
    return sensors_container.get_node(sensor_id) as Sensor

func has_sensor(sensor_id : String) -> bool:
    return sensors_container.has_node(sensor_id)
