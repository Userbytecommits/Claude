extends Node
class_name SpriteGenerator

static func create_player_texture(width: int = 32, height: int = 32) -> Image:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)

	for y in range(height):
		for x in range(width):
			var color = Color.BLACK

			var cx = float(x) / width
			var cy = float(y) / height

			if abs(cx - 0.5) < 0.25 and abs(cy - 0.35) < 0.25:
				color = Color.WHITE
			elif abs(cx - 0.5) < 0.35 and cy > 0.55:
				color = Color.WHITE

			image.set_pixel(x, y, color)

	return image

static func create_enemy_texture(width: int = 32, height: int = 32, enemy_type: String = "blob") -> Image:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)

	for y in range(height):
		for x in range(width):
			var color = Color.TRANSPARENT

			var cx = float(x - width/2) / (width/2)
			var cy = float(y - height/2) / (height/2)
			var dist = sqrt(cx*cx + cy*cy)

			if enemy_type == "blob":
				if dist < 0.7 + 0.1 * sin(cx * 6.28):
					color = Color.RED
				elif dist < 0.9:
					color = Color(0.8, 0.2, 0.2)
			elif enemy_type == "spike":
				if abs(cx) < 0.4 and abs(cy) < 0.8:
					color = Color.DARK_RED
				elif abs(cx) < 0.2 and abs(cy) < 1.0:
					color = Color.RED

			image.set_pixel(x, y, color)

	return image

static func create_tile_texture(width: int = 32, height: int = 32, tile_type: String = "stone") -> Image:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)

	for y in range(height):
		for x in range(width):
			var color = Color.WHITE

			if tile_type == "stone":
				color = Color(0.5, 0.5, 0.5) if (x + y) % 4 < 2 else Color(0.6, 0.6, 0.6)
			elif tile_type == "puzzle":
				color = Color(0.2, 0.6, 1.0) if (x + y) % 8 < 4 else Color(0.1, 0.4, 0.8)
			elif tile_type == "spike":
				if y < height/3:
					color = Color.RED
				else:
					color = Color(0.3, 0.3, 0.3)
			elif tile_type == "ice":
				color = Color(0.7, 0.9, 1.0)

			image.set_pixel(x, y, color)

	return image
