extends PanelContainer

signal update_battery(topic, sensor, value)

export (PackedScene) var line_chart : PackedScene

onready var charts_container : VBoxContainer = $Charts/ChartsContainer
onready var cards_container : VBoxContainer = $Charts/SensorCardsContainer

var dataframe_list : Array = []
var charts : Array = []

export (PackedScene) var Card : PackedScene

var cards : Array = []
var sensors : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass
#    if OS.get_name() == "Android":
#        charts_container.hide()
#        cards_container.show()
#    else:
#        charts_container.show()
#        cards_container.hide()
    
func build_card(datetime : Dictionary, topic : String, payload : String) -> void:
    yield(get_tree().create_timer(1), "timeout")
    var data_row : Array = payload.split(",")
    var sensor : String = data_row[0]
    var batt := float(data_row.pop_back())
    var card : PanelContainer = check_card(sensor)
    var anomalies := UTILS.get_anomalies(data_row)
    data_row.pop_front()
    card.set_values(data_row + [UTILS.get_percentage(batt)], anomalies)
    emit_signal("update_battery", topic, sensor, batt)

func check_card(sensor : String) -> PanelContainer:
    if sensors.has(sensor):
        return cards[sensors.find(sensor)]
    else:
        var card : PanelContainer = Card.instance()
        sensors.append(sensor)
        cards.append(card)
        cards_container.add_child(card)
        card.set_sensor_name(sensor)
        return card

func build_dataframe(datetime : Dictionary, topic : String, payload : String) -> void:
    var data_row : Array = payload.split(",")
    var sensor : String = data_row.pop_front()
    var dataframe : DataFrame = check_sensor(sensor)
    var battery = data_row.pop_back()
    var csv_row : PoolStringArray = dataframe.insert_row(data_row, UTILS.format_hour(datetime))
    plot_dataframe(dataframe)
    emit_signal("update_battery",topic, sensor, float(battery))

func check_sensor(sensor_name : String) -> DataFrame:
    if has_dataframe(sensor_name):
        return get_dataframe(sensor_name)
    else:
        var dataframe : DataFrame = DataFrame.new(Matrix.new(), UTILS.SENSOR_HEADERS, [], sensor_name)
        dataframe_list.append(dataframe)
        charts.append(build_line_chart(sensor_name))
        return dataframe

func build_line_chart(sensor_name : String) -> LineChart:
    var linechart : LineChart = line_chart.instance()
    charts_container.add_child(linechart)
    linechart.are_values_columns = true
    linechart.show_x_values_as_labels = true
    linechart.set_template(1)
    linechart.set_y_decim(0.2)
    linechart.set_only_disp_values(Vector2(0,10))
    linechart.set_treshold(Vector2(0,1000))
    linechart.set_chart_name(sensor_name)
    return linechart

func plot_dataframe(dataframe : DataFrame) -> void:
    var linechart : LineChart = charts[dataframe_list.find(dataframe)]
    linechart.call_deferred("plot_from_dataframe", dataframe)
    #linechart.plot_from_dataframe(dataframe)
    #print(dataframe)

func has_dataframe(sensor_name : String) -> bool:
    for dataframe in dataframe_list:
        if dataframe.table_name == sensor_name:
            return true
    return false

func get_dataframe(sensor_name : String) -> DataFrame:
    for dataframe in dataframe_list:
        if dataframe.table_name == sensor_name:
            return dataframe
    return null  



func check_treshold(payload : String) -> void:
    var pool_payload : Array = payload.split(",")
    check_battery(pool_payload[0], pool_payload.pop_back())
    var anomalies : PoolIntArray = UTILS.get_anomalies(pool_payload)
    if 1 in anomalies or 2 in anomalies:
        var msg : String = UTILS.build_tg_treshold_message(anomalies, pool_payload)
        Global.tg_bot.send_message(TelegramMessage.new(
            Global.firefliot_chat, 
            msg, 
            TelegramMessage.ParseModes.HTML))


func check_battery(sensor : String, battery_val : String) -> void:
    var batt : float = UTILS.get_percentage(float(battery_val))
    if batt <= Global.SensorValues.batt_treshold:
        var msg : String = UTILS.build_tg_battery_message(sensor, batt)
        Global.tg_bot.send_message(TelegramMessage.new(
            Global.firefliot_chat, 
            msg, 
            TelegramMessage.ParseModes.HTML))

                


func _on_CheckButton_toggled(button_pressed):
    if button_pressed:
        $Charts/CheckButton.set_text("Cards")
        charts_container.show()
        cards_container.hide()
    else:
        $Charts/CheckButton.set_text("Charts")
        charts_container.hide()
        cards_container.show()
