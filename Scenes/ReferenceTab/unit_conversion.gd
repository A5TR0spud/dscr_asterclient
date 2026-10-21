extends Control

@onready var metre: SpinBox = $Length/Metrimeter
@onready var akermeter: SpinBox = $Length/Akermeter
@onready var lightasec: SpinBox = $Length/Lightakersecond
@onready var lightsec: SpinBox = $Length/Lightsecond
@onready var au: SpinBox = $Length/AU
@onready var lightyear: SpinBox = $Length/Lightyear
@onready var foot: SpinBox = $Length/Feet

const ASEC_TO_SECOND: float = Main.HE6_HALF_LIFE
const LIGHTYEAR_TO_METRE: float = 9460730472580800
const C_METERS_PER_SECOND: float = 299792458
const C_AKERMETERS_PER_ASEC: float = 134217728
#const AKERMETER_TO_METRE: float = 1.80173581924
const AKERMETER_TO_METRE: float = C_METERS_PER_SECOND * ASEC_TO_SECOND / C_AKERMETERS_PER_ASEC
const AU_TO_METRE: float = 149597870700
const FOOT_TO_METER: float = 0.3048

var length_in_meters: float = 0

func update_lengths():
	akermeter.set_value_no_signal(length_in_meters / AKERMETER_TO_METRE)
	metre.set_value_no_signal(length_in_meters)
	lightasec.set_value_no_signal(length_in_meters * AKERMETER_TO_METRE / C_AKERMETERS_PER_ASEC)
	lightsec.set_value_no_signal(length_in_meters / C_METERS_PER_SECOND)
	au.set_value_no_signal(length_in_meters / AU_TO_METRE)
	lightyear.set_value_no_signal(length_in_meters / LIGHTYEAR_TO_METRE)
	foot.set_value_no_signal(length_in_meters / FOOT_TO_METER)

func _on_akermeter_value_changed(value: float):
	length_in_meters = value * AKERMETER_TO_METRE
	update_lengths()

func _on_metrimeter_value_changed(value: float):
	length_in_meters = value
	update_lengths()

func _on_lightakersecond_value_changed(value):
	length_in_meters = value / AKERMETER_TO_METRE * C_AKERMETERS_PER_ASEC
	update_lengths()

func _on_lightsecond_value_changed(value):
	length_in_meters = value * C_METERS_PER_SECOND
	update_lengths()

func _on_au_value_changed(value):
	length_in_meters = value * AU_TO_METRE
	update_lengths()

func _on_lightyear_value_changed(value):
	length_in_meters = value * LIGHTYEAR_TO_METRE
	update_lengths()

func _on_feet_value_changed(value):
	length_in_meters = value * FOOT_TO_METER
	update_lengths()
