extends HSlider

@export var bus_name:String
@export var bus_index:int


func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	if bus_name == "Music":
		$".".value = Globals.music_volume
	else:
		$".".value = Globals.sfx_volume
	value_changed.connect(_on_value_changed)
	AudioServer.set_bus_volume_db(bus_index,
	linear_to_db($".".value)
	)
	
	
func _on_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(bus_index,
	linear_to_db(value)
	)
	if bus_name == "Music":
		Globals.music_volume = $".".value
	else:
		Globals.sfx_volume = $".".value
