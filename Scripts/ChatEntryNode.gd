extends Resource
class_name ChatEntryNode
@export
var message: PackedInt64Array = []
@export
var sender: int = -1
@export
var trx: int = -1
@export
var date_timestamp: float = 0
@export
var channel: int = 0
@export
var has_channel: bool = false
@export
var earlier_in_channel: int = -1
@export
var later_in_channel: int = -1
