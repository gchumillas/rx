module reactive

@[heap]
struct Context {
mut:
	effect_stack   []&Effect
	next_effect_id int
}

pub fn new_context() &Context {
	return &Context{
		next_effect_id: 1
	}
}

pub fn (ctx &Context) new_signal[T](value T) &Signal[T] {
	return &Signal[T]{
		ctx:         ctx
		value:       value
		subscribers: map[int]fn (){}
	}
}
