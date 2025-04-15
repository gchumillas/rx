module main

import rx
import html

// A simple counter component
fn counter_component() html.Element {
	mut ctx := rx.context()
	mut count := ctx.signal(0)

	do_increment := fn [mut count]() {
		count.set(count.get() + 1)
	}

	mut span := html.create_element(tag_name: 'span')
	ctx.create_effect(fn [count, mut span]() {
		span.set_inner_text('${count.get()}')
	})

	mut button := html.create_element(tag_name: 'button')
	button.set_inner_text('Increment')
	button.add_event_listener('click', do_increment)

	return html.create_element(
		tag_name: 'div'
		children: [span, button]
	)
}

fn main() {
	mut app := html.get_element_by_id('app')?
	app.render(counter_component)
}
