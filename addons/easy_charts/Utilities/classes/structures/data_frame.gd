tool
extends Resource
class_name DataFrame

var ECUT

var table_name : String = ""
var labels : PoolStringArray = []
var headers : PoolStringArray = []
var datamatrix : Matrix = null
var dataset : Array = []

func _init(datamatrix : Matrix, headers : PoolStringArray = [], labels : PoolStringArray = [] , table_name : String = "") -> void:
    if labels.empty() : for label in range(datamatrix.get_size().x) : labels.append(label as String)
    if headers.empty() : for header in range(datamatrix.get_size().y) : headers.append(MatrixGenerator.get_letter_index(header))
    build_dataframe(datamatrix, headers, labels, table_name)

func build_dataframe(datamatrix : Matrix, headers : PoolStringArray = [], labels : PoolStringArray = [] , table_name : String = "") -> void:
    self.datamatrix = datamatrix
    self.table_name = table_name
    self.labels = labels
    self.headers = headers
    self.dataset = build_dataset_from_matrix(datamatrix, headers, labels)

func build_dataset(data : Array, headers : PoolStringArray, labels : PoolStringArray) -> Array:
    var dataset : Array = [Array([""]) + Array(headers)]
    for row_i in range(data.size()): dataset.append([labels[row_i]]+data[row_i])
    return dataset

func build_dataset_from_matrix(datamatrix : Matrix, headers : PoolStringArray, labels : PoolStringArray) -> Array:
    var data : Array = datamatrix.to_array()
    return build_dataset(data, headers, labels)

func insert_column(column : Array, header : String = "", index : int = dataset[0].size()) -> void:
    headers.insert(index, header if header != "" else MatrixGenerator.get_letter_index(index))
    datamatrix.insert_column(column, index-1)
    dataset = build_dataset_from_matrix(datamatrix, headers, labels)

func insert_row(row : Array, label : String = "", index : int = dataset.size()) -> PoolStringArray:
    labels.insert(index-1, label if label != "" else (index-1) as String)
    datamatrix.insert_row(row, index-1)
    dataset = build_dataset_from_matrix(datamatrix, headers, labels)
    return PoolStringArray([label] + row)

func get_datamatrix() -> Matrix:
    return datamatrix

func get_dataset() -> Array:
    return dataset

func get_labels() -> PoolStringArray:
    return labels

func transpose():
    build_dataframe(MatrixGenerator.transpose(datamatrix), labels, headers, table_name)

func _to_string() -> String:
    var last_string_len : int
    for row in dataset:
        for column in row:
            var string_len : int = str(column).length()
            last_string_len = string_len if string_len > last_string_len else last_string_len
    var string : String = "\n"
    for row_i in dataset.size():
        for column_i in dataset[row_i].size():
            string+="%*s" % [last_string_len+1, dataset[row_i][column_i]]
        string+="\n"
    string+="['{table_name}' : {rows} rows x {columns} columns]\n".format({
        rows = datamatrix.rows(), 
        columns = datamatrix.columns(),
        table_name = table_name})
    return string

# ...............................................................................

# Return a list of headers corresponding to a list of indexes
func get_headers_names(indexes : PoolIntArray) -> PoolStringArray:
    var headers : PoolStringArray = []
    for index in indexes:
        headers.append(dataset[0][index])
    return headers

# Returns the index of an header
func get_column_index(header : String) -> int:
    for headers_ix in range(dataset[0].size()):
        if dataset[0][headers_ix] == header: 
            return headers_ix
    return -1

# Get a column by its header
func get_column(header : String) -> Array:
    var headers_i : int = get_column_index(header)
    if headers_i!=-1: 
        return datamatrix.get_column(headers_i)
    else:
        return []

# Get a list of columns by their headers
func columns(headers : PoolStringArray) -> Matrix:
    var values : Array = []
    for header in headers:
        values.append(get_column(header))
    return MatrixGenerator.transpose(Matrix.new(values))


# Get a column by its index
func get_icolumn(index : int) -> Array:
    return datamatrix.get_column(index)

# Get a list of columns by their indexes
func get_icolumns(indexes : PoolIntArray) -> Array:
    var values : Array = []
    for index in indexes:
        values.append(datamatrix.get_column(index))
    return values

# Returns the list of labels corresponding to the list of indexes
func get_labels_names(indexes : PoolIntArray) -> PoolStringArray:
    var headers : PoolStringArray = []
    for index in indexes:
        headers.append(dataset[index][0])
    return headers

# Returns the index of a label
func get_row_index(label : String) -> int:
    for row in dataset.size():
        if dataset[row][0] == label:
            return row
    return -1

# Get a row by its label
func get_row(label : String) -> Array:
    var index : int = get_row_index(label)
    if index == -1 :
        return []
    else:
        return datamatrix.get_row(index)

# Get a list of rows by their labels
func rows(labels : Array) -> Matrix:
    var values : Array = []
    for label in labels:
        values.append(get_row(label))
    return Matrix.new(values)

# Get a row by its index
func get_irow(index : int) -> Array:
    return datamatrix.get_row(index)

# Get a list of rows by their indexes
func get_irows(indexes : PoolIntArray) -> Array:
    var values : Array = []
    for index in indexes:
        values.append(datamatrix.get_row(index))
    return values

# Returns a a group of rows or a group of columns, using indexes or names
# dataset["0;5"] ---> Returns an array containing all rows from the 1st to the 4th
# dataset["0:5"] ---> Returns an array containing all columns from the 1st to the 4th
# dataset["label0;label5"] ---> Returns an array containing all row from the one with label == "label0" to the one with label == "label5"
# dataset["header0:header0"] ---> Returns an array containing all columns from the one with label == "label0" to the one with label == "label5"
func _get(_property : String):
    # ":" --> Columns 
    if ":" in _property:
        var property : PoolStringArray = _property.split(":")
        if (property[0]).is_valid_integer(): 
            if property[1] == "*":
                return get_icolumns(range(property[0] as int, headers.size()-1))
            else:
                return get_icolumns(range(property[0] as int, property[1] as int +1))
        else:
            if property[1] == "*":
                return get_icolumns(range(get_column_index(property[0]), headers.size()-1))
            else:
                return get_icolumns(range(get_column_index(property[0]), get_column_index(property[1])))    
    # ";" --> Rows 
    elif ";" in _property:
        var property : PoolStringArray = _property.split(";")
        if (property[0]).is_valid_integer(): 
            return get_irows(range(property[0] as int, property[1] as int + 1 ))
        else: 
            return get_irows(range(get_row_index(property[0]), get_row_index(property[1])))
    elif "," in _property:
        var property : PoolStringArray = _property.split(",")
    else:
        if (_property as String).is_valid_integer():
            return get_icolumn(_property as int)
        else:
            return get_column(_property)
