module main

import rx

// A simple counter component
fn counter_component() &rx.HTMLElement {
	mut ctx := rx.context()
	mut count := ctx.signal(0)

	mut span := rx.create_element('span')
	span.set_inner_text('${count.get()}')

	ctx.create_effect(fn [count, mut span]() {
		span.set_inner_text('${count.get()}')
	})

	mut button := rx.create_element('button')
	button.set_inner_text('Increment')
	button.add_event_listener('click', fn [mut count]() {
		count.set(count.get() + 1)
	})

	mut div := rx.create_element('div')
	div.append_child(span)
	div.append_child(button)

	return div
}

fn main() {
	mut app := rx.get_element_by_id('app')?
	app.render(counter_component)
}
