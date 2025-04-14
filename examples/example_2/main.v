module main

import rx
import html

// A simple counter component
fn counter_component() &html.HTMLElement {
	mut ctx := rx.context()
	mut count := ctx.signal(0)

	mut span := html.create_element('span')
	span.set_inner_text('${count.get()}')

	ctx.create_effect(fn [count, mut span]() {
		span.set_inner_text('${count.get()}')
	})

	mut button := html.create_element('button')
	button.set_inner_text('Increment')
	button.add_event_listener('click', fn [mut count]() {
		count.set(count.get() + 1)
	})

	mut div := html.create_element('div')
	div.append_child(span)
	div.append_child(button)

	return div
}

fn main() {
	mut app := html.get_element_by_id('app')?
	app.render(counter_component)
}
