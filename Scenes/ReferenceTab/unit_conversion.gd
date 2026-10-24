extends Control

@onready var metre: SpinBox = $Length/Metrimeter
@onready var akermeter: SpinBox = $Length/Akermeter
@onready var lightasec: SpinBox = $Length/Lightakersecond
@onready var lightsec: SpinBox = $Length/Lightsecond
@onready var au: SpinBox = $Length/AU
@onready var lightyear: SpinBox = $Length/Lightyear
@onready var foot: SpinBox = $Length/Feet

@onready var hesec: SpinBox = $Time/HeSec
@onready var cesec: SpinBox = $Time/CeSec
@onready var decminute: SpinBox = $Time/DecMinute
@onready var dechour: SpinBox = $Time/DecHour
@onready var decday: SpinBox = $Time/DecDay
@onready var octmonth: SpinBox = $Time/OctMonth
@onready var octyear: SpinBox = $Time/OctYear
@onready var decyear: SpinBox = $Time/DecYear

const SECONDS_PER_HE6: float = Main.HE6_HALF_LIFE
const LIGHTYEAR_TO_METRE: float = 9460730472580800
const C_METERS_PER_SECOND: float = 299792458
const C_AKERMETERS_PER_ASEC: float = 134217728
#const AKERMETER_TO_METRE: float = 1.80173581924
const AKERMETER_TO_METRE: float = C_METERS_PER_SECOND * SECONDS_PER_HE6 / C_AKERMETERS_PER_ASEC
const AU_TO_METRE: float = 149597870700
const FOOT_TO_METER: float = 0.3048

const SECONDS_PER_MINUTE: float = 60
const SECONDS_PER_HOUR: float = 3600
const SECONDS_PER_DAY: float = 86400
const SECONDS_PER_YEAR: float = 365.25 * SECONDS_PER_DAY
const HESEC_PER_AYEAR: float = 3528238
const HESEC_PER_AMONTH: float = 1006893

var length_in_meters: float = 0
var time_in_seconds: float = 0

func update_lengths():
	akermeter.set_value_no_signal(length_in_meters / AKERMETER_TO_METRE)
	metre.set_value_no_signal(length_in_meters)
	lightasec.set_value_no_signal(length_in_meters * AKERMETER_TO_METRE / C_AKERMETERS_PER_ASEC)
	lightsec.set_value_no_signal(length_in_meters / C_METERS_PER_SECOND)
	au.set_value_no_signal(length_in_meters / AU_TO_METRE)
	lightyear.set_value_no_signal(length_in_meters / LIGHTYEAR_TO_METRE)
	foot.set_value_no_signal(length_in_meters / FOOT_TO_METER)

func update_times():
	hesec.set_value_no_signal(time_in_seconds / SECONDS_PER_HE6)
	cesec.set_value_no_signal(time_in_seconds)
	decminute.set_value_no_signal(time_in_seconds / SECONDS_PER_MINUTE)
	dechour.set_value_no_signal(time_in_seconds / SECONDS_PER_HOUR)
	decday.set_value_no_signal(time_in_seconds / SECONDS_PER_DAY)
	decyear.set_value_no_signal(time_in_seconds / SECONDS_PER_YEAR)
	octmonth.set_value_no_signal(time_in_seconds / HESEC_PER_AMONTH / SECONDS_PER_HE6)
	octyear.set_value_no_signal(time_in_seconds / HESEC_PER_AYEAR / SECONDS_PER_HE6)

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

func _on_he_sec_value_changed(value):
	time_in_seconds = value * SECONDS_PER_HE6
	update_times()

func _on_ce_sec_value_changed(value):
	time_in_seconds = value
	update_times()

func _on_dec_minute_value_changed(value):
	time_in_seconds = value * SECONDS_PER_MINUTE
	update_times()

func _on_dec_hour_value_changed(value):
	time_in_seconds = value * SECONDS_PER_HOUR
	update_times()

func _on_dec_day_value_changed(value):
	time_in_seconds = value * SECONDS_PER_DAY
	update_times()

func _on_oct_month_value_changed(value):
	time_in_seconds = value * HESEC_PER_AMONTH * SECONDS_PER_HE6
	update_times()

func _on_oct_year_value_changed(value):
	time_in_seconds = value * HESEC_PER_AYEAR * SECONDS_PER_HE6
	update_times()

func _on_dec_year_value_changed(value):
	time_in_seconds = value * SECONDS_PER_YEAR
	update_times()
