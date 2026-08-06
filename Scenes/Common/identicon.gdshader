shader_type canvas_item;

uniform int Value: hint_range(0, 4095, 1) = 0;

void fragment() {
	int x = int(abs(UV.x - 0.5) * 5.0 + 0.5);
	int y = int(UV.y * 5.0);
	//COLOR.b = 0.0;
	//COLOR.r = float(x) / 2.;
	//COLOR.g = float(y) / 4.;
	int r = Value;
	
	if (r % 2 == 0) {
		y = 4 - y;
	}
	if (r % 3 == 0) {
		x = 2 - x;
	}
	y = (r % 5 + y) % 5;

	int idx = x + y * 3;
	if (y == 2) {
		idx += 6;
	}
	if (y > 2) {
		idx -= 3;
	}
	for (int i = 0; i <= 11; i++) {
		if (r % 2 == 0 && idx == i) {
			discard;
		}
		r/= 2;
	}
	if (idx == 12 && Value % 7 == 1) {
		discard;
	}
	if (idx == 13 && Value % 11 == 1) {
		discard;
	}
	if (idx == 14 && Value % 13 == 1) {
		discard;
	}
}