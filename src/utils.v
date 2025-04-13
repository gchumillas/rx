module rx

// A generic reference wrapper that allows for mutable access to values within closures.
// This is particularly useful in reactive contexts where values need to be modified within effects.
pub struct Ref[T] {
pub mut:
	value T
}

// Creates a new reference wrapper for the given value.
// This allows the value to be mutated within closures where direct mutation would not be possible.
pub fn ref[T](value T) &Ref[T] {
	return &Ref[T]{ value: value }
}
