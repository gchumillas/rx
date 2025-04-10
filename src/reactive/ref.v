module reactive

pub struct Ref[T] {
pub mut:
	value T
}

// TODO: rename to new_ref (or maybe ctx.ref(0))
pub fn Ref.new[T](value T) &Ref[T] {
	return &Ref[T]{ value: value }
}