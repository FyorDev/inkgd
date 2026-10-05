# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkFloatValue

# ############################################################################ #

func get_value_type():
	return Ink.ValueType.FLOAT

func get_is_truthy():
	return value != 0.0

func _init():
	value = 0.0

# The method takes a `InkStoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func cast(new_type, metadata = null):
	if new_type == self.value_type:
		return self

	if new_type == Ink.ValueType.BOOL:
		return InkBoolValue.new_with(false if value == 0 else true)

	if new_type == Ink.ValueType.INT:
		return InkIntValue.new_with(int(value))

	if new_type == Ink.ValueType.STRING:
		return InkStringValue.new_with(_float_to_string(value))

	InkUtils.throw_story_exception(bad_cast_exception_message(new_type), false, metadata)
	return null

# Mirrors upstream's `FloatValue.ToString()`, which formats with
# `value.ToString(InvariantCulture)`. Because upstream stores a single-precision
# float, whole numbers render without a trailing ".0" (e.g. 15.0 -> "15").
# Godot's `str(float)` always keeps the ".0", so it's stripped here for integral
# values. This overrides `InkValue._to_string()`, which is the path used when
# floats are rendered into the output stream.
func _to_string() -> String:
	return _float_to_string(value)

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

# String manipulation (rather than `int(value)`) is used to strip the trailing
# ".0" so that large whole floats (e.g. 1e20) don't overflow int64. Godot never
# emits scientific notation for these, so there's no ".0" embedded in an
# exponent to mishandle.
static func _float_to_string(float_value: float) -> String:
	var string_value := str(float_value)
	if string_value.ends_with(".0"):
		return string_value.substr(0, string_value.length() - 2)
	return string_value

func is_ink_class(type):
	return type == "FloatValue" || super.is_ink_class(type)

func get_ink_class():
	return "FloatValue"

static func new_with(val):
	var value = InkFloatValue.new()
	value._init_with(val)
	return value
