module main

import rx
import html

// A simple counter span component
struct CounterSpanProps {
	count rx.Signal[int]
}

fn counter_span(ctx &rx.Context, props CounterSpanProps) html.Element {
	count := props.count
	mut span := html.create_element(tag_name: 'span')
	ctx.create_effect(fn [mut span, count]() {
		span.set_inner_text('${count.get()}')
	})
	return span
}

// A simple increment button component
struct IncrementButtonProps {
	text     string
	on_click fn () @[required]
}

fn increment_button(ctx &rx.Context, props IncrementButtonProps) html.Element {
	mut btn := html.create_element(tag_name: 'button')
	btn.add_event_listener('click', props.on_click)
	btn.set_inner_text(props.text)
	return btn
}

// A simple counter component
fn counter_component() html.Element {
	mut ctx := rx.context()
	mut count := ctx.signal(0)

	do_increment := fn [mut count]() {
		count.set(count.get() + 1)
	}

	return html.create_element(
		tag_name: 'div'
		children: [
			counter_span(ctx, struct {
				count
			})
			increment_button(ctx, struct {
				text: 'Increment',
				on_click: do_increment
			})
		]
	)
}

fn main() {
	mut app := html.get_element_by_id('app')?
	app.render(counter_component)
}
