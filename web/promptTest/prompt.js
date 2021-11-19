/**
 * Create custom prompt windows that may contain text, buttons, and inputs.
 */

"use strict";


// Append the prompt elements to the body
function addPromptElements() {
	// add the prompt elements to the body
	let container = document.createElement("div")
	container.className = "prompt-container"
	container.innerHTML = "<div class='prompt-window'><div class='prompt-content'><span class='prompt-header'></span><p class='prompt-text'></p></div><div class='prompt-items'></div></div>"
	document.getElementsByTagName("body")[0].appendChild(container)

	// Get the stylesheet for the prompt and add it to the head
	let linkCSS = document.createElement("link")
	linkCSS.rel = "stylesheet"
	linkCSS.href = "https://darvil82.github.io/DarviLStuff/web/promptTest/prompt.css"
	document.getElementsByTagName("head")[0].appendChild(linkCSS)
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
	constructor(title, body, ItemsArray=null) {
		this.title = title || ""
		this.text = body || ""
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



/** A prompt button that can be pressed by the user.
 *  When the user clicks it, the callback supplied will be called and the prompt will hide. */
class PromptButton {
	/**
	 * @param {string} text - The text to display on the button
	 * @param {Array} colors - CSS colors to use for the gradient of the button background
	 * @param {function} callback - The function to call when the button is pressed
	**/
	constructor(text, colorsArray, callback=null) {
		this.text = text || "Button"
		this.colors = colorsArray || []
		this.callback = callback || (() => {})
	}

	getElement() {
		let b = document.createElement("button")
		b.style.backgroundImage = `linear-gradient(90deg, ${this.colors.toString()})`
		b.innerHTML = this.text

		b.addEventListener("click", () => { this.clickButton() })
		return b
	}

	clickButton() {
		Prompt.hide()
		this.callback()
	}
}



/** A prompt input that lets the user enter text.
 *  The value entered can be obtained through the `value` property. */
class PromptInput {
	#id;

	/**
	 * @param {string} placeholder - The placeholder text to display in the input
	 * @param {string} defaultText - The default text value inside the input
	 * @param {string} width - CSS width of the input box
	 */
	constructor(placeholder=null, defaultText=null, width=null) {
		this.placeholder = placeholder || ""
		this.defaultText = defaultText || ""
		this.width = width || "100%"

		this.#id = "prompt-input" + parseInt(Math.random()*100)
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
 *  space between the prompt items */
class PromptSpacer {
	/**
	 * @param {string} width - The CSS width of the spacer
	 * @param {string} shapeWidth - The CSS width of the spacer shape
	 * @param {string} shapeColor - The CSS color of the spacer shape
	 */
	constructor(width=null, shapeWidth=null, shapeColor=null) {
		this.width = PromptSpacer.getWidth(width) || "0"
		this.shapeWidth = shapeWidth || "0"
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




// Easy to use functions like the alert() and prompt() built-ins.


/** A prompt window that will display a message to the user.
 * @param {string} title - The title of the prompt
 * @param {string} body - The body of the prompt
 */
function showAlert(title, body) {
	let a = new Prompt(title, body, [ new PromptButton("Ok") ])
	a.show()
}


/** A prompt will window that will ask the user to input a value.
 * @param {string} title - The title of the prompt
 * @param {string} body - The body of the prompt
 * @param {function} callback - The function to call with the value of the input when the user presses the OK button
 * @param {string} defaultValue - The default value of the input
 */
function showPrompt(title, body, callback, defaultValue=null) {
	let inputText = new PromptInput(null, defaultValue)
	let p = new Prompt(
		title, body,
		[
			inputText,
			new PromptSpacer(),
			new PromptButton("Cancel"),
			new PromptButton("Ok", ["green", "lime"], () => {
				callback(inputText.value)
			}),
		]
	)
	p.show()
}