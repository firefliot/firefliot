extends Node


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
