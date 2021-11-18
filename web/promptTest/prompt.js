"use strict";


// Append the prompt elements to the body
function addPromptElements() {
	let container = document.createElement("div")
	container.className = "prompt-container"
	container.innerHTML = "<div class='prompt-window'><div class='prompt-content'><span class='prompt-header'></span><p class='prompt-text'></p></div><div class='prompt-items'></div></div>"
	document.getElementsByTagName("body")[0].appendChild(container)
}
addPromptElements()

// Constants pointing to the elements that we'll use.
const CONTAINER = document.querySelector('.prompt-container');
const PROMPT = {
	header: document.querySelector('.prompt-header'),
	text: document.querySelector('.prompt-text'),
	items: document.querySelector(".prompt-items")
}



/** A prompt window that may have some properties like text and items */
class Prompt {
	/**
	 * @param {string} title - The title of the prompt
	 * @param {string} body - The body of the prompt
	 * @param {Array} ItemsArray - An array of items to be displayed in the prompt
	 */
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



/** A prompt button that can be pressed by the user **/
class PromptButton {
	/**
	 * @param {string} text - The text to display on the button
	 * @param {Array} colors - CSS colors to use for the gradient of the button background
	 * @param {function} callback - The function to call when the button is pressed
	**/
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



/** A prompt input that lets the user enter text **/
class PromptInput {
	#id;

	/**
	 * @param {string} placeholder - The placeholder text to display in the input
	 * @param {string} defaultText - The default text value inside the input
	 * @param {string} width - CSS width of the input box
	 */
	constructor(placeholder, defaultText, width) {
		this.placeholder = placeholder || ""
		this.defaultText = defaultText || ""
		this.width = width || "100%"

		this.#id = "prompt-input" + parseInt(Math.random()*1000)
	}

	getElement() {
		let i = document.createElement("input")
		i.placeholder = this.placeholder
		i.id = this.#id
		i.value = this.defaultText
		i.style.width = this.width
		return i
	}

	get value() {
		return document.getElementById(this.#id).value
	}
}



/** A prompt spacer that basically just adds a little
 *  space between the prompt items **/
class PromptSpacer {
	/**
	 * @param {string} width - The CSS width of the spacer
	 * @param {string} shapeWidth - The CSS width of the spacer shape
	 * @param {string} shapeColor - The CSS color of the spacer shape
	 */
	constructor(width, shapeWidth, shapeColor) {
		this.width = PromptSpacer.getWidth(width) || "0"
		this.shapeWidth = PromptSpacer.getWidth(shapeWidth) || "0"
		this.shapeColor = shapeColor || "#1f1f1f"
	}

	static getWidth(width) {
		if (!width) return 0
		if (width.startsWith("-")) {
			return 0
		}
		return width
	}

	getElement() {
		let s = document.createElement("div")
		s.style.marginInline = this.width
		s.style.backgroundColor = this.shapeColor
		s.style.width = this.shapeWidth
		return s
	}
}