class_name SigDB

static func support_dscr(sig: int) -> bool:
	return DictionaryHandler.support_dscr and DictionaryHandler.contains_signal(sig)

#region Non-human
## DSCR command to stop viewing a channel
const CHANNEL_LEAVE: int = -65533
## DSCR command to start viewing a channel
const CHANNEL_JOIN: int = -65534
## DSCR command to send the current message to a particular channel
const CHANNEL_SELECTOR: int = -65535
## When shown as a channel, displays all channels
const CHANNEL_SKELETON_KEY: int = -65536
#endregion

#region Format
## Splits digits into numbers
const DELIMIT: int = -2
## "["
const GROUP_START = -14
## ","
const SEP = -3
## "]"
const GROUP_END = -15
## "And then" or "is followed by". Pertains to any ordering, but especially with respect to time
const SEQUENCE = -122
##"var"
const VARIABLE = -11
#endregion

#region Math
##"-"
const NEGATIVE = -1
##"."
const DECIMAL = -10
## e, of Euler fame
const EULER = -805
## pi, of circle fame
const sPI = -806
## tau, of circle fame
const sTAU = -354405
## phi, of golden ratio fame
const PHI = -604002
## Square root of 0, but greater than 0. Machine epsilon
const EPSILON_0 = -157428
## Surreal number. Less than all positive real numbers but greater than 0.
const EPSILON_S = -329
## Add the previous 2 terms
const ADD = -5
## Multiply the previous 2 terms
const MULT = -6
## Of the previous 2 terms, subtract the second from the first
const SUB = -7
## Of the previous 2 terms, divide the first by the second
const DIV = -8
## Of the previous 2 terms, take the first term to the power of the second
const POW = -9
## Take the absolute length of the previous item
const LENGTH = -20
## Of the previous 2 terms, truncate and/or round the first term to the amount of digits equal to the second term's quantity
const SIGFIG_ROUND = -24
## Of the previous 2 terms, take the first term to the power of the reciprocal of the second term
const ROOT = -252
## Take the natural log of the previous term
const NATLOG = -804
const SINE = -807
const COSINE = -808
const TANGENT = -809
const FACTORIAL = -101135
const DEGREE = -101141
const RADIAN = -101142
const LOGARITHM = -157414
## Sign or normalize
const NORMALIZE = -157456
const MODULO = -354406
#endregion

#region Confetti!
## Confetti!
const CONFETTI: int = -702
## Nothing. Nada. Zilch. Zero.
const NIL: int = -111
## Neutralization
const NOT: int = -29
## "Can categorically be considered a"
const IS_OF: int = -99
## Is, be, are, am
const IS: int = -100
## Logical conjunction
const AND: int = -30
## "it logically follows"
const THEN: int = -36
#endregion

#region Rendering
## Instruction to render
const RENDER: int = -53
## Instruction to draw a sphere
const RENDER_SPHERE : int = -52 #center x, center y, center z, diameter, color
## Cube
const CUBE : int = -524000 #center x, center y, center z, diameter, color
## Rectangular prism
const BOX  : int = -157442 #center x, center y, center z, x length, y length, z length, color
## Instruction to draw a line
const RENDER_LINE : int = -326 #x0, y0, z0, x1, y1, z1, color
#endregion

#region Audiating
## Instruction to generate audio
const SONG = -577
## Instruction to play a note.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const NOTE = -605003
## Instruction to play a note using a sine wave.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const WAVE_SINE = -807
## Instruction to play random noise.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const NOTE_NOISE = -157403
## Instruction to play a note using a saw wave.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const WAVE_SAW = -157457
## Instruction to play a note using a triangle wave.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const WAVE_TRI = -157458
## Instruction to play a note using a square wave.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const WAVE_SQUARE = -157459
## Instruction to play a note approximating a dog's bark or woof.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const SOUND_BARK = -310
## Instruction to play a note approximating a cat's meow.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const SOUND_MEOW = -311
## Instruction to play a note approximating a bird's chirp.[br]
## Followed by starting time, time length, frequency[br]
## Time is measured by the half-life of He-6
const SOUND_CHIRP = -312
#endregion
