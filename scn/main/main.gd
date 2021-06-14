extends Control
class_name Main

onready var side_bar : SideBar = $MainContainer/DockContainer/SideBar
onready var docks_container : VBoxContainer = $MainContainer/DockContainer/Docks
onready var dashboard : PanelContainer = docks_container.get_node("Dashboard")
onready var database : PanelContainer = docks_container.get_node("Database")

var factory_topic : String = "firefliotsensor_tecnarredo-abi03421/#"

var default_size : Vector2
var resize_offset : Vector2
var docks : Array = []

var telegram_bot : TelegramBot

func _connect_signals() -> void:
    MQTT.connect("MessageReceived",self,"_on_message_received")
    MQTT.connect("Connected",self,"_on_connected")
    MQTT.connect("Disconnected",self,"_on_disconnected")
    MQTT.connect("MessagePublished", self, "_on_message_published")
    MQTT.connect("Subscribed", self, "_on_subscribed")
    MQTT.connect("Unsubscribed", self, "_on_unsubscribed")
    dashboard.connect("update_battery", database, "update_battery")


func connect_mqtt_client() -> void:
    LOGGER.print_msg("connecting to MQTT broker...")
    var client : String = ""
    for n in 10:
        client += str(randi() % 21)
    MQTT.clientId = "mqttclient_"+client
    MQTT.ConnectClient(MQTT.mqttURI, MQTT.mqttPort, MQTT.clientId)

func _ready() -> void:
    _connect_signals()
    LOGGER.print_msg("server started")
    randomize()
    connect_mqtt_client()
    if Global.is_client():
        default_size = OS.get_window_size()
        $MainContainer/TopBar.set_window_name("firefliot Desktop")
        load_docks()
    if Global.is_server():
        Global.connect_telegram_bot()
    

func load_docks() -> void:
    for dock in docks_container.get_children():
        dock.hide()
        docks.append(dock)
    side_bar.press_button(side_bar.buttons[0])


# ................ MQTT signaling
func _on_message_received(topic : String, payload : String) -> void:
    LOGGER.print_mqtt_msg(1, topic, payload)
    var time : Dictionary = OS.get_datetime()
    var l_topic : String = Array(topic.split("/")).back()
    match l_topic:
        "status":
            if Global.is_client():
                database.update_status(time, topic, payload)
            LOGGER.log_csv_data(time, topic, payload.split(","), l_topic)
            
        "value":
            if Global.is_client():
                if OS.get_name() == "Android":
                    dashboard.build_card(time, topic, payload)
                else:
                    dashboard.build_dataframe(time, topic, payload)
            else:
                dashboard.check_treshold(payload)
            LOGGER.log_csv_data(time, topic, payload.split(","), l_topic)

    
func _on_message_published(topic : String, payload : String) -> void:
    LOGGER.print_mqtt_msg(0, topic, payload)


func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        LOGGER.print_msg("shutting down...")
        get_tree().quit() # default behavior

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

# ------------------- mQTT
func _on_connected() -> void:
    LOGGER.print_msg("connected to {ip} MQTT broker as: {client}".format({ip = MQTT.mqttURI, client = MQTT.clientId}))
    MQTT.SubscribeToTopic(factory_topic)
    MQTT.PublishMessage(MQTT.client_topic,"?status",false,1)

func _on_disconnected() -> void:
    LOGGER.print_msg("disconnected")


func _on_subscribed(topic : String) -> void:
    LOGGER.print_msg("subscribed to %s" % topic)


func _on_unsubscribed(topics : PoolStringArray) -> void:
    LOGGER.print_msg("unsubscribed from %s" % topics.join(","))
