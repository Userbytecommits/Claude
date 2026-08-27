extends CanvasLayer
class_name TouchControls

## Virtual on-screen controls for mobile: a left/right pad and jump/dash
## buttons, driving the same input actions the keyboard uses so Player
## needs no touch-specific code.

@onready var left_btn: TouchScreenButton = $LeftButton
@onready var right_btn: TouchScreenButton = $RightButton
@onready var jump_btn: TouchScreenButton = $JumpButton
@onready var dash_btn: TouchScreenButton = $DashButton

func _ready():
	# Keep visible on all platforms so touch input is always testable;
	# real device builds could hide this on desktop via OS.has_feature("mobile").
	pass
