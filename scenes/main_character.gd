extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready    var jump_sound:	AudioStreamPlayer2D =	$KarakterLompat
@onready    var flag:	Area2D =  get_parent().get_node("Flag")
@onready    var flag_sound:	AudioStreamPlayer2D =	get_parent().get_node("Flag/Finish")
@onready	var weapon_anim:	AnimationPlayer =	$Weapon/AnimationPlayer
@onready	var weapon_sprite:	Sprite2D =	$Weapon/WeaponSprite
@onready 	var slash_sound: AudioStreamPlayer2D = $Weapon/SlashSound

var	is_attacking	=	false

func _ready() -> void:
	# Hubungkan sinyal untuk menangani ketika karakter menyentuh bendera
	if flag:
		flag.body_entered.connect(Callable(self, "_on_flag_body_entered"))
	else:
		push_warning("❌ Node Area2D (bendera) tidak ditemukan!")

	# Hubungkan sinyal selesai animasi serangan
	if weapon_anim:
		weapon_anim.animation_finished.connect(_on_weapon_animation_finished)
	else:
		push_warning("❌ AnimationPlayer untuk Weapon tidak ditemukan!")

func _physics_process(delta: float) -> void:
	# Tambahkan gravitasi jika tidak di lantai
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0.0

	# Lompat jika tombol ditekan dan sedang di lantai
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
	
	# Serangan pedang (klik kiri)
	if Input.is_action_just_pressed("attack_click") and not is_attacking:
		if weapon_anim.has_animation("slash"):
			weapon_anim.play("slash")
			slash_sound.play()
		attack()

	# Gerak kiri dan kanan
	if not is_attacking:
		var direction	:=	Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x	=	direction * SPEED
		else:
			velocity.x	=	move_toward(velocity.x, 0, SPEED)

	# Gerakkan karakter
	move_and_slide()

func _on_flag_body_entered(body):
	if body == self:
		print("🏁 Level selesai!")
		if  flag_sound:
				flag_sound.play()


func attack():
	is_attacking	=	true
	$Weapon/HitBox.monitoring = true 
	weapon_anim.play("slash")


func _on_weapon_animation_finished(anim_name):
	if anim_name	==	"slash":
		is_attacking	=	false
		$Weapon/HitBox.monitoring = false
