extends Node

const sensors_log : String = "sensors.log"

var log_file_path : String = "user://system/sensor_logs/{date}/"
var current_date : Dictionary
var log_file : File
var current_file : String

signal new_log(file)
signal log_line(line)

func _ready() -> void:
    create_new_logpath()

func create_new_logpath() -> void:
    current_date = OS.get_datetime(true)
    log_file = File.new()
    
    # create log directory
    var directory : Directory = Directory.new()
    var log_dir : String = log_file_path.format({date = UTILS.format_date(current_date)})
    if not directory.dir_exists(log_dir):
        directory.make_dir_recursive(log_dir)
    
    current_file = log_dir + sensors_log
    
    # create sensors log file
    if not directory.file_exists(current_file):
        log_file.open(current_file, File.WRITE)
        log_file.close()
    
    emit_signal("new_log", current_file)

func log_data(data : Dictionary) -> void:
    var datetime : Dictionary = OS.get_datetime()
    if datetime.day > current_date.day:
        create_new_logpath()
    log_file.open(current_file, File.READ_WRITE)
    log_file.seek_end()
    var line : String = "[{time}] --> {data}".format({time = UTILS.format_hour(datetime), data = JSON.print(data)})
    log_file.store_line(line)
    log_file.close()
    emit_signal("log_line", line)
