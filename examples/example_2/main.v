module main

import js.dom

fn main() {
	mut div := dom.document.getElementById('app'.str)?

	// adds a paragraph
	mut p := dom.document.createElement('p'.str)
	p.textContent = 'Hi from V!'.str
	div.appendChild(p)

	// adds a button
	mut btn := dom.document.createElement('button'.str)
	btn.textContent = 'Click me!'.str
	div.appendChild(btn)

	// adds an event listener
	btn.addEventListener('click'.str, fn [mut p] (_ JS.Event) {
		p.textContent = 'Button clicked!'.str
	}, JS.EventListenerOptions{})
}
