extends Node

const bot_token : String = "1744361693:AAGs49ycp9-BXI6YtR_o8fKRT_HObawDqLA"
const firefliot_chat : String = "-524116531"

var tg_bot : TelegramBot

class SensorValues:
    const temp_treshold := 35.0
    const hum_treshold := 55.0
    const press_treshold := 1100.0
    const tvoc_treshold := 300.0
    const co2_treshold := 5000.0
    const batt_treshold := 4.0
    const labels : PoolStringArray = PoolStringArray(["Temperatura", "Umiditá", "Pressione", "eCO2", "TVOC", "Batteria"])
    const units : PoolStringArray = PoolStringArray(["°C", "%", "hPa", "PPM", "PPB", "%"])
    const anomalies : PoolRealArray = PoolRealArray([temp_treshold, hum_treshold, press_treshold, co2_treshold, tvoc_treshold, batt_treshold])
    const deltas : PoolRealArray = PoolRealArray([5.0, 10.0, 10.0, 50.0, 70.0, 10.0])

func connect_telegram_bot() -> void:
    tg_bot = TelegramAPI.get_bot(bot_token)

func is_client() -> bool:
    return (OS.has_feature("client") or OS.get_name() == "Windows")

func is_server() -> bool:
    return (OS.has_feature("server") or OS.get_name() == "X11")
