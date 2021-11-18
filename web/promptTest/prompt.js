"use strict";


// Append the prompt elements to the body
function addPromptElements() {
	let container = document.createElement("div")
	container.className = "prompt-container"
	container.innerHTML = "<div class='prompt-window'><div class='prompt-content'><span class='prompt-header'></span><p class='prompt-text'></p></div><div class='prompt-buttons'></div></div>"
	document.getElementsByTagName("body")[0].appendChild(container)
}
addPromptElements()

// Constants pointing to the elements that we'll use.
const CONTAINER = document.querySelector('.prompt-container');
const PROMPT = {
	header: document.querySelector('.prompt-header'),
	text: document.querySelector('.prompt-text'),
	items: document.querySelector(".prompt-buttons")
}






// A prompt window that may have some properties like text and buttons
class Prompt {
	constructor(title, body, ItemsArray) {
		this.title = title
		this.text = body
		this.items = ItemsArray || [ new PromptButton("Ok") ]
	}

	show() {
		PROMPT.header.innerHTML = this.title;
		PROMPT.text.innerHTML = this.text;

		// remove all the buttons and set the new ones
		Array.from(PROMPT.items.children).forEach(e => {PROMPT.items.removeChild(e)})
		this.items.forEach(e => {
			PROMPT.items.appendChild(e.getElement())
		})

		Prompt.display()
	}

	static isShown() { return (CONTAINER.classList.contains("shown")) }
	static display() { CONTAINER.classList.add("shown") }
	static hide() { CONTAINER.classList.remove("shown") }
}



// A prompt button that may be used inside a Prompt
class PromptButton {
	constructor(text, colorsArray, callback) {
		this.text = text || "Button"
		this.colors = colorsArray || []
		this.callback = callback || (() => {})
	}

	getElement() {
		let b = document.createElement("button")
		b.innerHTML = this.text
		b.style.backgroundImage = `linear-gradient(90deg, ${this.colors.toString()})`
		b.addEventListener("click", () => {this.clickButton()})
		return b
	}

	clickButton() {
		Prompt.hide()
		this.callback()
	}
}



// A prompt input that may be used inside a Prompt
class PromptInput {
	constructor(placeholder, defaultText, width) {
		this.placeholder = placeholder || ""
		this.defaultText = defaultText || ""
		this.width = width || "100%"

		this.id = "prompt-input" + parseInt(Math.random()*1000)
	}

	getElement() {
		let i = document.createElement("input")
		i.placeholder = this.placeholder
		i.id = this.id
		i.value = this.defaultText
		i.style.width = this.width
		return i
	}

	get value() {
		return document.getElementById(this.id).value
	}
}