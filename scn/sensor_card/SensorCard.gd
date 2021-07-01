extends PanelContainer

onready var Card = $Card
onready var SensorName = Card.get_node("Label")
onready var Column1 = $Card/Container/Column1
onready var Column2 = $Card/Container/Column2
onready var Temperature = Column1.get_node("Temperature/Container/Value")
onready var Humidity = Column1.get_node("Humidity/Container/Value")
onready var Pressure = Column1.get_node("Pressure/Container/Value")
onready var ECO2 = Column2.get_node("ECO2/Container/Value")
onready var TVOC = Column2.get_node("TVOC/Container/Value")
onready var Battery = Column2.get_node("Battery/Container/Value")

onready var labels : Array = [Temperature, Humidity, Pressure, ECO2, TVOC, Battery]
# Called when the node enters the scene tree for the first time.
func _ready():
    SensorName.set_text("")
    Temperature.set_text("")
    Pressure.set_text("")
    Humidity.set_text("")
    ECO2.set_text("")
    TVOC.set_text("")
    Battery.set_text("")

func set_sensor_name(name : String):
    SensorName.set_text(name)

func set_values(values : Array, anomalies : Array):
    for id in range(0, anomalies.size()):
        match anomalies[id]:
            0: labels[id].modulate = Color.white
            1: labels[id].modulate = Color.yellow
            2: labels[id].modulate = Color.red
    if values.back() <= Global.SensorValues.batt_treshold:
        Battery.modulate = Color.yellow
    for val in range(0, values.size()):
        labels[val].set_text(str(values[val])+ " "+ Global.SensorValues.units[val])
