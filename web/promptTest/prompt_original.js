/**
 * Create custom prompt windows that may contain text, buttons, and inputs.
 * Written by David Losantos.
 *
 * Wiki available at https://github.com/DarviL82/DarviLStuff/wiki/prompt.js
 */

"use strict";



(function() {
	// Get the stylesheet for the prompt and add it to the head
	let linkCSS = document.createElement("link")
	linkCSS.rel = "stylesheet"
	linkCSS.href = "https://darvil82.github.io/DarviLStuff/web/promptTest/prompt.css"
	document.querySelector("head").appendChild(linkCSS)

	// add the prompt elements to the body
	let container = document.createElement("div")
	container.className = "prompt-container"
	container.innerHTML = `
		<div class='prompt-window'>
			<div class='prompt-content'>
				<span class='prompt-header'></span>
				<p class='prompt-text'></p>
			</div>
			<div class='prompt-items'></div>
		</div>
	`
	document.querySelector("body").appendChild(container)
})()


// Constants pointing to the elements that we'll use.
const CONTAINER = document.querySelector('.prompt-container');
const WPROMPT = {
	header: document.querySelector('.prompt-header'),
	text: document.querySelector('.prompt-text'),
	items: document.querySelector(".prompt-items")
}


/**
 * Gets keyboard-focusable elements in the body
 * @param {HTMLElement} excludeParent - The element parent to exclude its children
 * @returns {HTMLElement[]} The array of elements
 */
function getKeyboardFocusableElements(excludeParent=null) {
	return [...document.querySelector("body").querySelectorAll(
		'a[href], button, input, textarea, select, details, [tabindex]'
	)]
	.filter(
		el => !el.hasAttribute("disabled")
		&& !el.getAttribute("aria-hidden")
		&& !el.parentElement.isSameNode(excludeParent)
	)
}


const ELEMENTS_TAB_INDEX = { globalState: true }
/** Sets the tabIndex of all the elements in the DOM, except the ones inside the prompt container */
function setTabIndex(value=true) {
	const elements = getKeyboardFocusableElements(WPROMPT.items)

	if (value) {
		elements.forEach(e => e.tabIndex = ELEMENTS_TAB_INDEX[e])
		ELEMENTS_TAB_INDEX.globalState = true
	} else if (ELEMENTS_TAB_INDEX.globalState) {
		elements.forEach(e => ELEMENTS_TAB_INDEX[e] = e.tabIndex )
		elements.forEach(e => e.tabIndex = -1)
		ELEMENTS_TAB_INDEX.globalState = false
	}
}




/** A prompt window that may have some properties like text and items */
class Prompt {
	static #itemCounter = 0; // used to give each prompt item a unique ID

	/**
	 * @param {string} title - The title of the prompt
	 * @param {string} body - The body of the prompt
	 * @param {Array} itemsArray - An array of items to be displayed in the prompt
	 * @param {boolean} vertical - Will the items be displayed vertically or horizontally?
	 */
	constructor(title, body, itemsArray=null, vertical=false) {
		this.title = title || ""
		this.text = body || ""
		this.items = itemsArray || [ new PromptButton("Ok") ]
		this.isVertical = vertical || window.innerWidth < 600 	// If the window is small, display the items vertically
	}

	/** Generate the prompt window with all the elements, and show it */
	show() {
		WPROMPT.header.innerHTML = this.title;
		WPROMPT.text.innerHTML = this.text;
		WPROMPT.items.style.flexDirection = (this.isVertical) ? "column" : "row"

		// remove all the buttons and set the new ones
		Array.from(WPROMPT.items.children).forEach(e => WPROMPT.items.removeChild(e))
		this.items.forEach(e => {
			WPROMPT.items.appendChild(e.getElement(this.isVertical))
		})

		Prompt.display()
	}

	/** Return the state of the window */
	static get isShown() { return (CONTAINER.classList.contains("shown")) }

	/** Shows the prompt window with the elements already added */
	static display() {
		CONTAINER.classList.add("shown")
		document.querySelector("body").style.overflowY = "hidden"
		setTabIndex(false)
	}

	/** Hides the prompt window */
	static hide() {
		CONTAINER.classList.remove("shown")
		document.querySelector("body").style.overflowY = ""
		setTabIndex(true)
	}

	static getNextItemID() { return "prompt-item-" + Prompt.#itemCounter++ }
}




/** A prompt button that can be pressed by the user.
 *  When the user presses it, the callback supplied will be called. */
class PromptButton {
	/**
	 * @param {string} text - The text to display on the button
	 * @param {Array} colorsArray - CSS colors to use for the gradient of the button background
	 * @param {function} callback - The function to call when the button is pressed
	 * @param {string} width - CSS width of the button
	 * @param {boolean} closePromptOnPress - Will the prompt be closed when the button is pressed?
	**/
	constructor(text, colorsArray=null, callback=null, width=null, closePromptOnPress=true) {
		this.text = text || "Button"
		this.colors = colorsArray || []
		this.callback = callback || (() => {})
		this.width = width || ""
		this.closePromptOnPress = closePromptOnPress
	}

	/** Return the HTML element with the properties specified */
	getElement() {
		let b = document.createElement("button")
		b.style.backgroundImage = `linear-gradient(180deg, ${this.colors.toString()})`
		b.innerHTML = this.text
		b.style.width = this.width

		b.addEventListener("click", () => this.press())
		return b
	}

	/** Call the callback function and hide the prompt if the closePromptOnPress property is true */
	press() {
		if (this.closePromptOnPress)
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
	 * @param {function} callback - The function to call with the value when the Enter key is pressed
	 */
	constructor(placeholder=null, defaultText=null, width=null, callback=null) {
		this.placeholder = placeholder || ""
		this.defaultText = defaultText || ""
		this.width = width || "100%"
		this.callback = callback || (() => {})

		this.#id = Prompt.getNextItemID()
	}

	getElement() {
		let i = document.createElement("input")
		i.placeholder = this.placeholder
		i.id = this.#id
		i.value = this.defaultText
		i.style.width = this.width

		i.addEventListener("keydown", e => {
			if (e.key == "Enter") this.callback(this.value)
		})

		return i
	}

	/** Return the value entered by the user */
	get value() { return document.getElementById(this.#id).value }
}



/** A prompt input that lets the user select an option from a list of options.
 *  The value entered can be obtained through the `value` property, and the index
 *  of it in the options array with the `index` property. */
class PromptOptionList {
	#id;

	/**
	 * @param {Array} optList - An array of options (strings) to display in the list
	 * @param {string} selectedIndex - The index of the selected option by default. Default value is 0.
	 * @param {string} width - CSS width of the input box
	 * @param {function} callback - The function to call with the value and index when the value is changed
	*/
	constructor(optList, selectedIndex=null, width=null, callback=null) {
		this.optList = optList
		this.selectedIndex = selectedIndex || 0
		this.width = width || ""
		this.callback = callback || (() => {})

		this.#id = Prompt.getNextItemID()
	}

	getElement() {
		let i = document.createElement("select")
		i.id = this.#id
		i.style.width = this.width

		PromptOptionList.getOptionElements(this.optList).forEach(e => {
			if (this.selectedIndex == this.optList.indexOf(e.innerHTML))
				e.selected = true
			i.appendChild(e)
		})

		i.addEventListener("change", () => this.callback(this.value, this.index))

		return i
	}

	/** Return the option elements from the options array */
	static getOptionElements(optList) {
		return [...optList.map(opt => {
			let e = document.createElement("option")
			e.innerHTML = opt
			return e
		})]
	}

	/** Return the value entered by the user */
	get value() { return document.getElementById(this.#id).value }

	/** Return the index of the selected option on the options */
	get index() { return document.getElementById(this.#id).selectedIndex }
}



/** A prompt spacer that basically just adds a little
 *  space between the prompt items. */
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

	getElement(isVertical) {
		let div = document.createElement("div")
		if (isVertical) {
			div.style.marginBlock = this.width
			div.style.height = this.shapeWidth
		} else {
			div.style.marginInline = this.width
			div.style.width = this.shapeWidth
		}
		div.style.backgroundColor = this.shapeColor
		return div
	}
}




// Easy to use functions like the alert() and prompt() built-ins.


/** A prompt window that will display a message to the user.
 * @param {string} title - The title of the prompt
 * @param {string} body - The body of the prompt
 */
function showAlert(title, body) {
	new Prompt(title, body, [ new PromptButton("Ok") ]).show()
}


/** A prompt window that will ask the user to input a value.
 * @param {string} title - The title of the prompt
 * @param {string} body - The body of the prompt
 * @param {function} callback - The function to call with the value of the input when the user presses the OK button
 * @param {string} defaultValue - The default value of the input
 */
function showPrompt(title, body, callback, defaultValue=null) {
	let inputText = new PromptInput(null, defaultValue, null, () => okButton.press())
	let okButton = new PromptButton("Ok", ["lime", "green"], () => { callback(inputText.value) })

	new Prompt(
		title, body,
		[
			inputText,
			new PromptSpacer(),
			new PromptButton("Cancel"),
			okButton
		]
	).show()
}


/** A prompt window that will ask the user to select the Ok or Cancel button.
 * @param {string} title - The title of the prompt
 * @param {string} body - The body of the prompt
 * @param {function} okCallback - The function to call when the user presses the OK button
 * @param {function} cancelCallback - The function to call when the user presses the Cancel button
 */
function showConfirm(title, body, okCallback, cancelCallback=null) {
	new Prompt(
		title, body,
		[
			new PromptButton("Cancel", ["red", "darkred"], cancelCallback),
			new PromptButton("Ok", ["lime", "green"], okCallback)
		]
	).show()
}