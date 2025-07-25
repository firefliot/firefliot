tool
extends Resource
class_name Matrix

var values : Array = []

func _init(matrix : Array = [], size : int = 0) -> void:
    values = matrix

func insert_row(row : Array, index : int = values.size()) -> void:
    if rows() != 0:
        assert(row.size() == columns(), "the row size must match matrix row size")
    values.insert(index, row)

func insert_column(column : Array, index : int = values[0].size()) -> void:
    if columns() != 0:
        assert(column.size() == rows(), "the column size must match matrix column size")
    for row_idx in column.size():
        values[row_idx].insert(index, column[row_idx])

func to_array() -> Array:
    return values.duplicate(true)

func get_size() -> Vector2:
    return Vector2(rows(), columns())

func rows() -> int:
    return values.size()

func columns() -> int:
    return values[0].size() if rows() != 0 else 0

func get_column(column : int) -> Array:
    assert(column < columns(), "index of the column requested (%s) exceedes matrix columns (%s)"%[column, columns()])
    var column_array : Array = []
    for row in values: 
        column_array.append(row[column])
    return column_array

func get_columns(from : int, to : int) -> Array:
    var values : Array = []
    for column in range(from, to):
        values.append(get_column(column))
    return values
#    return MatrixGenerator.from_array(values)

func get_row(row : int) -> Array:
    assert(row < rows(), "index of the row requested (%s) exceedes matrix rows (%s)"%[row, rows()])
    return values[row]

func get_rows(from : int, to : int) -> Array:
    return values.slice(from, to)
#    return MatrixGenerator.from_array(values)    

func _to_string() -> String:
    var last_string_len : int
    for row in values:
        for column in row:
            var string_len : int = str(column).length()
            last_string_len = string_len if string_len > last_string_len else last_string_len
    var string : String = "\n"
    for row_i in values.size():
        for column_i in values[row_i].size():
            string+="%*s" % [last_string_len+1 if column_i!=0 else last_string_len, values[row_i][column_i]]
        string+="\n"
    return string

# --------------
func _get(_property : String):
    # ":" --> Columns 
    if ":" in _property:
        var property : PoolStringArray = _property.split(":") 
        var from : PoolStringArray = property[0].split(",")
        var to : PoolStringArray = property[1].split(",")
    elif "," in _property:
        var property : PoolStringArray = _property.split(",")
        if property.size() == 2:
            return get_row(property[0] as int)[property[1] as int]
    else:
        if (_property as String).is_valid_integer():
            return get_row(_property as int)






