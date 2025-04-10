module reactive

pub struct Ref[T] {
pub mut:
	value T
}

pub fn ref[T](value T) &Ref[T] {
	return &Ref[T]{ value: value }
}