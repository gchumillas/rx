module rx

import js.dom

const document = dom.document

pub struct HTMLElement {
mut:
	native_element JS.HTMLElement
}

pub type Component = fn () &HTMLElement

pub fn get_element_by_id(id string) ?&HTMLElement {
	native_element := document.getElementById(id.str)?

	return &HTMLElement{
		native_element: native_element
	}
}

pub fn create_element(tag_name string) &HTMLElement {
	return &HTMLElement{
		native_element: document.createElement(tag_name.str)
	}
}

pub fn (target &HTMLElement) add_event_listener(event string, cb fn ()) {
	target.native_element.addEventListener(
		event.str,
		fn [cb] (_ JS.Event) { cb() },
		JS.EventListenerOptions{}
	)
}

pub fn (target &HTMLElement) render(comp Component) {
	target.native_element.appendChild(comp().native_element)
}

pub fn (mut target HTMLElement) append_child(el &HTMLElement) {
	target.native_element.appendChild(el.native_element)
}

pub fn (target &HTMLElement) get_inner_text() string {
	return string(target.native_element.innerText)
}

pub fn (mut target HTMLElement) set_inner_text(text string) {
	target.native_element.innerText = text.str
}