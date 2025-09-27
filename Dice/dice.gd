extends Sprite2D

@export var all_possible_faces: Array[DiceFaceDataResource]

var options : Array[DiceFaceDataResource]
var interval : float = 0.1
var timer : int = 10
var previewInterval : float = 1
var active : bool = true
var preview : bool = false
var isFinished : bool = false
var rng: RandomNumberGenerator
var ticks: int  = timer
var choice:DiceFaceDataResource

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	generate_new_dice()

## Input control
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and ticks == timer:
		roll()
	if event.is_action_pressed("ui_cancel") and ticks == timer:
		generate_new_dice()

## Inicia el roll del dado
func roll() -> void:
	ticks = 0
	isFinished = false
	##Iniciemos el timer con el intervalo de espera para ver el "roll" del dado
	##Estoy abierto a mejoras
	$TimerRoll.wait_time = interval
	$TimerRoll.start()

## Cada vez que se el timer acabe cambia la textura hasta que ticks sea igual a timer
func _on_timer_timeout() -> void:
	##Cuando se acabe el tiempo de espera, que haga el "roll". Si aún no ha acabado el tiempo (timer), reiniciamos el timer
	##Sigo diciendo, estoy abierto a mejoras. Me disculpo con quien tenga que leer esto
	ticks = ticks + 1
	if ticks < timer:
		choice = options.pick_random()
		self.texture = choice.texture
	else:
		$TimerRoll.stop()
		isFinished = true
	
## Change faces of dice
func generate_new_dice():
	options.clear()
	for i in range(6):
		options.append(all_possible_faces.pick_random())
	
	self.texture = options.pick_random().texture

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
