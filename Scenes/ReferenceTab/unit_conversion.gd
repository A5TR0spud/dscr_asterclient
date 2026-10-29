extends Control

@onready var metre: SpinBox = $Length/Metrimeter
@onready var akermeter: SpinBox = $Length/Akermeter
@onready var lightasec: SpinBox = $Length/Lightakersecond
@onready var lightsec: SpinBox = $Length/Lightsecond
@onready var au: SpinBox = $Length/AU
@onready var lightyear: SpinBox = $Length/Lightyear
@onready var inch: SpinBox = $Length/Inches
@onready var foot: SpinBox = $Length/Feet
@onready var mile: SpinBox = $Length/Miles

@onready var hesec: SpinBox = $Time/HeSec
@onready var cesec: SpinBox = $Time/CeSec
@onready var decminute: SpinBox = $Time/DecMinute
@onready var dechour: SpinBox = $Time/DecHour
@onready var decday: SpinBox = $Time/DecDay
@onready var octmonth: SpinBox = $Time/OctMonth
@onready var octyear: SpinBox = $Time/OctYear
@onready var decyear: SpinBox = $Time/DecYear

@onready var akergram: SpinBox = $Mass/Akergram
@onready var kilogram: SpinBox = $Mass/Kilogram
@onready var pound: SpinBox = $Mass/Pound
@onready var stone: SpinBox = $Mass/Stones
@onready var slug: SpinBox = $Mass/Slugs
@onready var ton: SpinBox = $Mass/ImpTon
@onready var supermass: SpinBox = $Mass/Supermass
@onready var earthmass: SpinBox = $Mass/Earth
@onready var solarmass: SpinBox = $Mass/Sol

const SECONDS_PER_HE6: float = Main.HE6_HALF_LIFE
const LIGHTYEAR_TO_METRE: float = 9460730472580800
const C_METERS_PER_SECOND: float = 299792458
const C_AKERMETERS_PER_ASEC: float = 134217728
const AKERMETER_TO_METRE: float = C_METERS_PER_SECOND * SECONDS_PER_HE6 / C_AKERMETERS_PER_ASEC
const AU_TO_METRE: float = 149597870700
const FOOT_TO_METER: float = 0.3048
const FEET_PER_MILE: float = 5280

const SECONDS_PER_MINUTE: float = 60
const SECONDS_PER_HOUR: float = 3600
const SECONDS_PER_DAY: float = 86400
const SECONDS_PER_YEAR: float = 365.25 * SECONDS_PER_DAY
const HESEC_PER_AYEAR: float = 3528238
const HESEC_PER_AMONTH: float = 1006893

const KILOGRAMS_PER_AKERGRAM: float = 14.3728158895040179409107756612273792975412133888
const AKERGRAMS_PER_SUPERMASS: float = 3586098686288827308324625.693278208
const KILOGRAMS_PER_POUND: float = 0.45359237
const POUNDS_PER_STONE: float = 14
const KILOGRAMS_PER_EARTH: float = 5.9722e+24
const KILOGRAMS_PER_SUN: float = 1.988416e+30
const POUNDS_PER_TON: float = 2240
const POUNDS_PER_SLUG: float = 32.17405

var length_in_meters: float = 0
var time_in_seconds: float = 0
var mass_in_kilograms: float = 0

func _ready():
	Main.instance.reload_dictionary_support.connect(refresh_dict_support)

func refresh_dict_support():
	var v: bool = DictionaryHandler.support_m0
	akermeter.visible = v
	lightasec.visible = v
	octmonth.visible = v
	octyear.visible = v
	akergram.visible = v
	supermass.visible = v

func _update_translation(node: Node):
	for child in node.get_children():
		if child is LocaleNode:
			child.refresh()

func update_lengths():
	akermeter.set_value_no_signal(length_in_meters / AKERMETER_TO_METRE)
	metre.set_value_no_signal(length_in_meters)
	lightasec.set_value_no_signal(length_in_meters / AKERMETER_TO_METRE / C_AKERMETERS_PER_ASEC)
	lightsec.set_value_no_signal(length_in_meters / C_METERS_PER_SECOND)
	au.set_value_no_signal(length_in_meters / AU_TO_METRE)
	lightyear.set_value_no_signal(length_in_meters / LIGHTYEAR_TO_METRE)
	inch.set_value_no_signal(length_in_meters / FOOT_TO_METER * 12)
	foot.set_value_no_signal(length_in_meters / FOOT_TO_METER)
	mile.set_value_no_signal(length_in_meters / FOOT_TO_METER / FEET_PER_MILE)
	
	for node  in [akermeter, metre, lightasec, lightsec, au, lightyear, inch, foot, mile]:
		_update_translation(node)

func update_times():
	hesec.set_value_no_signal(time_in_seconds / SECONDS_PER_HE6)
	cesec.set_value_no_signal(time_in_seconds)
	decminute.set_value_no_signal(time_in_seconds / SECONDS_PER_MINUTE)
	dechour.set_value_no_signal(time_in_seconds / SECONDS_PER_HOUR)
	decday.set_value_no_signal(time_in_seconds / SECONDS_PER_DAY)
	decyear.set_value_no_signal(time_in_seconds / SECONDS_PER_YEAR)
	octmonth.set_value_no_signal(time_in_seconds / HESEC_PER_AMONTH / SECONDS_PER_HE6)
	octyear.set_value_no_signal(time_in_seconds / HESEC_PER_AYEAR / SECONDS_PER_HE6)
	for node  in [hesec, cesec, decminute, dechour, decday, decyear, octmonth, octyear]:
		_update_translation(node)

func update_masses():
	akergram.set_value_no_signal(mass_in_kilograms / KILOGRAMS_PER_AKERGRAM)
	kilogram.set_value_no_signal(mass_in_kilograms)
	pound.set_value_no_signal(mass_in_kilograms / KILOGRAMS_PER_POUND)
	stone.set_value_no_signal(mass_in_kilograms / KILOGRAMS_PER_POUND / POUNDS_PER_STONE)
	slug.set_value_no_signal(mass_in_kilograms / KILOGRAMS_PER_POUND / POUNDS_PER_SLUG)
	ton.set_value_no_signal(mass_in_kilograms / KILOGRAMS_PER_POUND / POUNDS_PER_TON)
	supermass.set_value_no_signal(mass_in_kilograms / KILOGRAMS_PER_AKERGRAM / AKERGRAMS_PER_SUPERMASS)
	earthmass.set_value_no_signal(mass_in_kilograms / KILOGRAMS_PER_EARTH)
	solarmass.set_value_no_signal(mass_in_kilograms / KILOGRAMS_PER_SUN)
	for node  in [akergram, kilogram, pound, stone, slug, ton, supermass, earthmass, solarmass]:
		_update_translation(node)
		
func _on_akermeter_value_changed(value: float):
	length_in_meters = value * AKERMETER_TO_METRE
	update_lengths()

func _on_metrimeter_value_changed(value: float):
	length_in_meters = value
	update_lengths()

func _on_lightakersecond_value_changed(value):
	length_in_meters = value * AKERMETER_TO_METRE * C_AKERMETERS_PER_ASEC
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

func _on_inches_value_changed(value):
	length_in_meters = value * FOOT_TO_METER / 12
	update_lengths()

func _on_feet_value_changed(value):
	length_in_meters = value * FOOT_TO_METER
	update_lengths()

func _on_miles_value_changed(value):
	length_in_meters = value * FOOT_TO_METER * FEET_PER_MILE
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

func _on_akergram_value_changed(value):
	mass_in_kilograms = value * KILOGRAMS_PER_AKERGRAM
	update_masses()

func _on_pound_value_changed(value):
	mass_in_kilograms = value * KILOGRAMS_PER_POUND
	update_masses()

func _on_stones_value_changed(value):
	mass_in_kilograms = value * KILOGRAMS_PER_POUND * POUNDS_PER_STONE
	update_masses()

func _on_imp_ton_value_changed(value):
	mass_in_kilograms = value * KILOGRAMS_PER_POUND * POUNDS_PER_TON
	update_masses()

func _on_supermass_value_changed(value):
	mass_in_kilograms = value * KILOGRAMS_PER_AKERGRAM * AKERGRAMS_PER_SUPERMASS
	update_masses()

func _on_earth_value_changed(value):
	mass_in_kilograms = value * KILOGRAMS_PER_EARTH
	update_masses()

func _on_sol_value_changed(value):
	mass_in_kilograms = value * KILOGRAMS_PER_SUN
	update_masses()

func _on_kilogram_value_changed(value):
	mass_in_kilograms = value
	update_masses()

func _on_slugs_value_changed(value):
	mass_in_kilograms = value * KILOGRAMS_PER_POUND * POUNDS_PER_SLUG
	update_masses()
