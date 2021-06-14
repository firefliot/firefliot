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

func set_values(values : Array):
    Temperature.set_text(str(values[0])+Global.SensorValues.units[0])
    Humidity.set_text(str(values[1])+Global.SensorValues.units[1])
    Pressure.set_text(str(values[2])+" "+Global.SensorValues.units[2])
    ECO2.set_text(str(values[3])+" "+Global.SensorValues.units[3])
    TVOC.set_text(str(values[4])+" "+Global.SensorValues.units[4])
    Battery.set_text(str(values[5])+" "+Global.SensorValues.units[5])