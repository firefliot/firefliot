extends Node

const log_file_path : String = "user://logs/firefliot/"

var current_date : Dictionary
var log_file : File
var current_file : String

signal new_log(file)
signal log_line(line)

func _ready() -> void:
    check_path()

func check_path() -> void:
    # create log directory
    var directory : Directory = Directory.new()
    if not directory.dir_exists(log_file_path):
        directory.make_dir(log_file_path)

func log_debug(datetime : Dictionary, source : String, message : String) -> void:
    var directory : Directory = Directory.new()
    if not directory.dir_exists(log_file_path+"/debug/"):
        directory.make_dir_recursive(log_file_path+"/debug/")
    
    # Check log file
    var log_file : File = File.new()
    var log_path : String = "{root}/debug/{data}.log".format({root = log_file_path, data = UTILS.format_date(datetime)})
    if not directory.file_exists(log_path):
        log_file.open(log_path, File.WRITE)
        log_file.close()
        emit_signal("new_log", log_path)
    
    # Write on file
    log_file.open(log_path, File.READ_WRITE)
    log_file.seek_end()
    var line : String = "[%s] [%s] >> %s" % [source, UTILS.format_hour(datetime), message]
    log_file.store_line(line)
    log_file.close()
    if Global.is_server(): print(line)
    else: emit_signal("log_line", line)


func log_data(datetime : Dictionary, topic : String, data : Dictionary) -> void:
    # Check directory topic
    var directory : Directory = Directory.new()
    if not directory.dir_exists(log_file_path+"/"+topic):
        directory.make_dir_recursive(log_file_path+"/"+topic)
    
    # Check log file
    var log_file : File = File.new()
    var log_path : String = "{root}/{topic}/{data}.log".format({root = log_file_path, topic = topic, data = UTILS.format_date(datetime)})
    if not directory.file_exists(log_path):
        log_file.open(log_path, File.WRITE)
        log_file.close()
        emit_signal("new_log", log_path)
    
    # Write on file
    log_file.open(log_path, File.READ_WRITE)
    log_file.seek_end()
    var line : String = "[{time}] --> {data}".format({time = UTILS.format_hour(datetime), data = JSON.print(data)})
    log_file.store_line(line)
    log_file.close()
 #   if OS.has_feature("server"):
 #       printmsg(UTILS.format_hour(datetime), line)

func log_csv_data(datetime : Dictionary, topic : String, pool_data : PoolStringArray, t_head : String):
    var headers : PoolStringArray = []
    match t_head:
        "status": headers = ["status"]
        "value": headers = UTILS.SENSOR_HEADERS
    
    # Check directory topic
    var directory : Directory = Directory.new()
    if not directory.dir_exists(log_file_path+"/"+topic):
        directory.make_dir_recursive(log_file_path+"/"+topic)
    
    # Check log file
    var log_file : File = File.new()
    var log_path : String = "{root}/{topic}/{data}.csv".format({root = log_file_path, topic = topic, data = UTILS.format_date(datetime)})
    if not directory.file_exists(log_path):
        log_file.open(log_path, File.WRITE)
        log_file.store_csv_line(PoolStringArray([" "]) + headers)
        log_file.close()
    
    # Write on file
    log_file.open(log_path, File.READ_WRITE)
    log_file.seek_end()
    
    # substitute sensor's name with datetime to log incsv
    var csv_data : PoolStringArray = Array(pool_data).duplicate()
    csv_data[0] = UTILS.format_hour(datetime)
    
    log_file.store_csv_line(csv_data)
    log_file.close()

func print_msg(msg : String) -> void:
    log_debug(OS.get_datetime(), "firefliot", msg)

func print_mqtt_msg(type : int, topic : String, msg : String) -> void:
    var str_type : String
    match type:
        0: str_type = "PUBLISHED"
        1: str_type = "RECEIVED"
    var message := "%s {%s} > \"%s\"" % [str_type, topic, msg]
    log_debug(OS.get_datetime(), "mosquitto", message)
