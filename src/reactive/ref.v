module reactive

pub struct Ref[T] {
pub mut:
	value T
}

pub fn Ref.new[T](value T) &Ref[T] {
	return &Ref[T]{ value: value }
}