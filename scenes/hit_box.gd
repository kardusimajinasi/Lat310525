extends Area2D

func _ready():
    connect("body_entered", Callable(self, "_on_hitbox_body_entered"))

func _on_hitbox_body_entered(body):
    if body.name == "CharacterBody2D2":
        print("🔥 Musuh kena sabetan!")

        # Efek meledak (opsional)
        var particles = body.get_node_or_null("Explosion")
        if particles:
            particles.emitting = true

        body.queue_free()
