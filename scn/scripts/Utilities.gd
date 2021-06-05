extends Node

const SENSOR_HEADERS : PoolStringArray = PoolStringArray(["temp", "press", "hum", "eco2", "tvoc", "batt"])

func format_time_int(time_int : int) -> String:
    return (("0" if str(time_int).length() == 1 else "") + str(time_int))

func format_hour(time_dict : Dictionary) -> String:
    return "%s:%s:%s" % [
        format_time_int(time_dict.hour),
        format_time_int(time_dict.minute),
        format_time_int(time_dict.second)
       ]

func format_date(date_dict : Dictionary) -> String:
    return "%s-%s-%s" % [
        date_dict.day,
        date_dict.month,
        date_dict.year
       ]

func format_datetime(date_dict : Dictionary) -> String:
    return format_date(date_dict)+" "+format_hour(date_dict)

func get_percentage(volt : float) -> float:
    return stepify(range_lerp(volt, 2.9, 4.2, 0, 100),0.1)

func get_anomalies(_pool : Array) -> PoolIntArray:
    var anomalies : PoolIntArray = PoolIntArray([])
    var pool : PoolRealArray = PoolRealArray(_pool.duplicate())
    pool.remove(0)
    for i in range(0, pool.size()):
        if pool[i] >= Global.SensorValues.anomalies[i]:
            anomalies.append(2)
        else:
            if Global.SensorValues.anomalies[i] - pool[i] <= Global.SensorValues.deltas[i]:
                anomalies.append(1)
            else:
                anomalies.append(0)
    return anomalies

func build_tg_battery_message(sensor : String, battery : float) -> String:
    var msg : String = "<b>&#x1F50B; <code>%s</code> si sta scaricando.\n\n</b>" % sensor
    msg+="La batteria del sensore <code>%s</code> si sta scaricando.\n" % sensor
    msg+="Valore della batteria: <b>%s %s</b>" % [battery, Global.SensorValues.units[5]]
    return msg


func build_tg_treshold_message(anomalies : PoolIntArray, values : Array) -> String:
    var msg : String = "&#9888; <b>ATTENZIONE</b> &#9888;\n"
    msg+="<i>Rilevati valori anomali</i>\n\n"
    msg+="&#128100; Sensore: <code>%s</code> \n" % values.pop_front()
    for i in range(0, anomalies.size()-1):
        match anomalies[i]:
            0:
                pass
            1:
                msg+="&#128993; %s: <b>%s %s</b> \n" % [Global.SensorValues.labels[i], values[i], Global.SensorValues.units[i]]
            2:
                msg+="&#128308; %s: <b>%s %s</b> \n" % [Global.SensorValues.labels[i], values[i], Global.SensorValues.units[i]]
    return msg
