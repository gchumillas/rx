module reactive

@[heap]
struct Context {
mut:
	effect_stack   []&Effect
	next_effect_id int
}

pub fn context() &Context {
	return &Context{
		next_effect_id: 1
	}
}
