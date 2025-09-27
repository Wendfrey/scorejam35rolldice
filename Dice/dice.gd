extends Sprite2D

var options : Array
var interval : float = 0.1
var timer : int = 50
var previewInterval : float = 1
var active : bool = true
var preview : bool = false
var isFinished : bool = false
var rng
var ticks
var choice

func roll() -> void:
	ticks = 0
	isFinished = false
	rng = RandomNumberGenerator.new()
	##Iniciemos el timer con el intervalo de espera para ver el "roll" del dado
	##Estoy abierto a mejoras
	$TimerRoll.wait_time = interval
	$TimerRoll.start()

func _on_timer_timeout() -> void:
	##Cuando se acabe el tiempo de espera, que haga el "roll". Si aún no ha acabado el tiempo (timer), reiniciamos el timer
	##Sigo diciendo, estoy abierto a mejoras. Me disculpo con quien tenga que leer esto
	ticks = ticks + 1
	if ticks < timer:
		var opt : int = rng.randi_range(0, options.size() - 1)
		choice = options[opt]
		self.texture = load(str("res://Assets/Texture/",choice))
		$TimerRoll.start()
	else:
		isFinished = true
	


##Properties
#func _setOptions(newValue : Array) -> void:
	###Cuando se vuelvan a meter nuevas opciones para el dado, reajustemos el tamaño del array para evitar problemas en el random
	#options.resize(newValue.size())
	#options = newValue
	#
#func _getOptions() -> Array:
	#return options
#
#func _setInterval(newValue : float) -> void:
	#interval = newValue
		#
#func _getInterval() -> float:
	#return interval
#
#func _setTimer(newValue : int) -> void:
	#timer = newValue
		#
#func _getTimer() -> int:
	#return timer
#
#func _setPreviewInterval(newValue : float) -> void:
	#previewInterval = newValue
		#
#func _getPreviewInterval() -> float:
	#return previewInterval
	#
#func _setPreview(newValue : bool) -> void:
	#preview = newValue
		#
#func _getPreview() -> bool:
	#return preview
	#
#func setActive(newValue : bool) -> void:
	###TODO: Cambiar el color tambien a algo "inactivo"
	#active = newValue
	#
#func _getActive() -> bool:
	#return active
#
#func setIsFinished(newValue : bool) -> void:
	#isFinished = newValue
	#
#func _getIsFinished() -> bool:
	#return isFinished
