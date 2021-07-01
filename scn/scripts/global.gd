extends Node


const settings_path : String = "user://settings.cfg"
const bot_token : String = "1744361693:AAGs49ycp9-BXI6YtR_o8fKRT_HObawDqLA"
const firefliot_chat : String = "-524116531"

var tg_bot : TelegramBot

var SensorValues : Dictionary = {
    "temp_treshold" : 35.0,
    "hum_treshold" : 65.0,
    "press_treshold" : 1100.0,
    "tvoc_treshold" : 3.0,
    "co2_treshold" : 5000.0,
    "batt_treshold" : 30.0,
    "labels" : PoolStringArray(["Temperatura", "Umiditá", "Pressione", "eCO2", "TVOC", "Batteria"]),
    "units" : PoolStringArray(["°C", "%", "hPa", "PPM", "PPM", "%"]),
    "anomalies" : PoolRealArray([]),
    "deltas" : PoolRealArray([])
}

func _ready():
    var settings : ConfigFile = ConfigFile.new()
    var err = settings.load(settings_path)
    if err==OK:
        SensorValues.temp_treshold = settings.get_value("tresholds", "temp")
        SensorValues.hum_treshold = settings.get_value("tresholds", "hum", SensorValues.hum_treshold)
        SensorValues.press_treshold = settings.get_value("tresholds", "press", SensorValues.press_treshold)
        SensorValues.co2_treshold = settings.get_value("tresholds", "eco2", SensorValues.co2_treshold)
        SensorValues.tvoc_treshold = settings.get_value("tresholds", "tvoc", SensorValues.tvoc_treshold)
        SensorValues.batt_treshold = settings.get_value("tresholds", "batt", SensorValues.batt_treshold)
        SensorValues.deltas = settings.get_value("tresholds", "deltas", SensorValues.deltas)
        #OS.window_size = settings.get_value("window", "size", Vector2(1280,720))
    else:
        settings.set_value("tresholds", "temp", SensorValues.temp_treshold)
        settings.set_value("tresholds", "hum", SensorValues.hum_treshold)
        settings.set_value("tresholds", "press", SensorValues.press_treshold)
        settings.set_value("tresholds", "eco2", SensorValues.co2_treshold)
        settings.set_value("tresholds", "tvoc", SensorValues.tvoc_treshold)
        settings.set_value("tresholds", "batt", SensorValues.batt_treshold)
        settings.set_value("tresholds", "deltas", [5.0, 10.0, 10.0, 1200.0, 1.0])
        settings.save(settings_path)
    SensorValues.deltas = PoolRealArray([5.0, 10.0, 10.0, 1200.0, 1.0])
    SensorValues.anomalies = PoolRealArray([SensorValues.temp_treshold, SensorValues.hum_treshold, SensorValues.press_treshold, SensorValues.co2_treshold, SensorValues.tvoc_treshold, SensorValues.batt_treshold])

func connect_telegram_bot() -> void:
    tg_bot = TelegramAPI.get_bot(bot_token)

func is_client() -> bool:
    return (OS.has_feature("client") or OS.get_name() == "Windows")

func is_server() -> bool:
    return (OS.has_feature("server") or OS.get_name() == "X11")
