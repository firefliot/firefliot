extends Control
class_name Main

var dock_scene : PackedScene = preload("res://scn/dock/dock.tscn")
var sensor_status_bar_scene : PackedScene = preload("res://scn/sensor_status_bar/sensor_status_bar.tscn")

onready var side_bar : SideBar = $MainContainer/DockContainer/SideBar
onready var docks_container : VBoxContainer = $MainContainer/DockContainer/Docks
onready var line_chart : LineChart = $MainContainer/DockContainer/Docks/Dashboard/DockContainer/Row0/LineChart
onready var sensors_container : VBoxContainer = $MainContainer/DockContainer/Docks/Database/DockContainer/SensorsContainer

var default_size : Vector2
var resize_offset : Vector2
var docks : Array = []

var sensors : Array = []
var charts : Array = []
var dataframes : Array = []

func connect_mqtt_client() -> void:
    MQTT.ConnectClient(MQTT.mqttURI, MQTT.mqttPort, MQTT.clientId)
    MQTT.PublishMessage(MQTT.client_topic,"?status",false,1)
    MQTT.connect("MessageReceived",self,"_on_message_received")
    MQTT.SubscribeToTopic("firefliotsensor_tecnarredo-abi03421/#")


func _ready() -> void:
    default_size = OS.get_window_size()
    $MainContainer/TopBar.set_window_name("firefliot Desktop")
    load_docks()
    connect_mqtt_client()
    charts.append(line_chart)

func matrix_tests() -> void:
    var matrix : Matrix = MatrixGenerator.from_array([])
    print(matrix)
    var header : Array = ["sensor"]
    var index : Array = ["0001a"]
    var dataframe : DataFrame = DataFrame.new(matrix, index, header)
    print(dataframe)
    dataframe.insert_column("value1",[200])
    print(dataframe)
    dataframe.insert_row("0001b",[300])
    print(dataframe)
    dataframe.insert_column("value2",[400,350])
    print(dataframe)

func load_docks() -> void:
    for dock in docks_container.get_children():
        dock.hide()
        docks.append(dock)
    side_bar.press_button(side_bar.buttons[0])


# ................ MQTT signaling
func _on_message_received(topic : String, payload : String) -> void:
    print("[{topic}] > {payload}".format({"topic":topic, "payload":payload}))
    var topic_array : PoolStringArray = topic.split("/")
    var json_payload : Dictionary = JSON.parse(payload).result
    LOGGER.log_data(json_payload)
    if "/value" in topic:
        plot_esp(json_payload)
    if "/status" in topic:
        update_status(json_payload)

func add_new_sensor(sensor_code : String) -> void:
    sensors.append(sensor_code)
    var dataframe : DataFrame = DataFrame.new(MatrixGenerator.from_array(),[sensor_code],["sensor"])
    dataframes.append(dataframe)

func update_status(payload : Dictionary) -> void:
    if sensors_container.get_node_or_null(payload.sensor) == null:
        var sensor : Sensor = sensor_status_bar_scene.instance()
        sensors_container.add_child(sensor)
        sensor.setup_sensor(payload.sensor, "")
        add_new_sensor(payload.sensor)
    else:
        sensors_container.get_node(payload.sensor).set_status(payload.status)

func plot_esp(payload : Dictionary) -> void:
    var time : Dictionary = OS.get_time(true)
    var dataframe = dataframes[sensors.find(payload.sensor)]
    dataframe.insert_column("%s:%s:%s"%[time.hour, time.minute, time.second], [payload.tvoc])
    line_chart.clean_variables()
    line_chart.clear_points()
    line_chart.plot_from_dataframe(dataframe)
    print(dataframe)

func _process(delta) -> void:
    if Input.is_action_just_pressed("ui_left"): MQTT.PublishMessage(MQTT.client_topic,"?status",false,1)
    if Input.is_action_just_pressed("ui_right"): MQTT.PublishMessage(MQTT.client_topic,"r/wifi",false,1)
    if Input.is_action_just_pressed("ui_down"): MQTT.PublishMessage(MQTT.client_topic,"r/mqtt",false,1)

# .............. GUI signals
func _on_SideBar_button_pressed(btn_index : int, btn_name : String) -> void:
    for dock in docks: dock.hide() if dock.name != btn_name else dock.show()

# ........................ Window Control Signaling
func _on_TopBar_close() -> void:
    get_tree().quit()

func _on_TopBar_minimize() -> void:
    OS.set_window_minimized(not OS.is_window_minimized())

func _on_TopBar_resize() -> void:
    OS.set_window_maximized(not OS.is_window_maximized())

func _on_TopBar_moving_from_pos(event_pos : Vector2, offset : Vector2) -> void:
    OS.set_window_position(OS.get_window_position() + event_pos - offset)

