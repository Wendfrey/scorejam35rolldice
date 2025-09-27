class_name DiceFaceDataResource extends Resource

enum FaceColor {
	RED,
	BLUE,
	GREEN,
	WHITE,
	ALL
}

enum Effect {
	POSITIVE,
	NEGATIVE,
	ADD_DICE
}

@export var texture: Texture2D
@export var faceColor: FaceColor
@export var effect:Effect = Effect.POSITIVE
