extends Object
class_name ParseResult

enum FailureState {
	## Not yet initialized.
	UNPARSED,
	## Nothing has gone wrong, the output is whole
	ALL_GOOD,
	## Array size exceeds maximum transmission signal quantity
	TOO_LONG,
	## Unknown strings could not be parsed
	UNKNOWN_STRING
}

## Current state of the result, i.e., whether it contains strings or not
var state: FailureState = FailureState.UNPARSED
## Array holding parsed integers
var output: Array[int] = [] as Array[int]
## Array of indices of the provided string that halted the parser, if the parsing failed to a(n) unknown string(s)
var stopping_indices: Array[int] = [] as Array[int]
## Array of failed strings
var failures: Array[String] = [] as Array[String]
