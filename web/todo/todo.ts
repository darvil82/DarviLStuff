/**
 * Get the template of a Todo
 */
function getTodoTemplate(): HTMLDivElement {
	return document.importNode(
		// @ts-ignore
		document.querySelector("[data-todo-template]").content, true
	).firstElementChild
}

// The container which holds all the todos
const container = document.querySelector(".todos-container")

// Options bar and it's inputs/buttons (opts)
const optionsBar = document.querySelector(".options")
const opts = {
	inputTitle: document.querySelector("[data-input='title']") as HTMLInputElement,
	inputBody: document.querySelector("[data-input='body']") as HTMLInputElement,
	inputColor: document.querySelector("[data-input='color']") as HTMLInputElement,
	delButton: document.querySelector("[data-input='remove']") as HTMLButtonElement,
	allButton: document.querySelector("[data-input='all']") as HTMLButtonElement
}

/**
 * Data that a Todo holds
 */
interface TodoInfo {
	title: string,
	body: string,
	date?: Date | string,
	color?: string
}[]

/**
 * This is all the data of each of all the todos that are currently in the container
 */
const currentTodos: TodoInfo[] = []


/**
 * Inserts a Todo into the container
 * @param options The options of the Todo
 * @param triggerSave Automatically save the todos after inserting
 */
function addTodo(
	options: TodoInfo,
	triggerSave = true
): boolean {
	let { title, body, date = new Date(), color } = options

	title = title.trim()

	if (!title) return false;

	const todo = getTodoTemplate()

	// set all the content of the todo
	if (color) todo.style.setProperty("--bg-color", color)
	todo.querySelector(".title").textContent = title
	todo.querySelector(".date").textContent = date.toLocaleString()
	todo.querySelector(".body").textContent = body
	todo.tabIndex = 0
	todo.dataset.todoNumber = `${currentTodos.length}`

	// add the click event to select it
	todo.addEventListener("keyup", e => { if (e.key == "Enter") todo.classList.toggle("selected") })
	todo.addEventListener("click", () => todo.classList.toggle("selected"))

	// play the animation and remove it after .5s
	todo.classList.add("in")
	setTimeout(() => todo.classList.remove("in"), 500)

	// add the element to the container with all the todos
	container.prepend(todo)

	// save this todo data to the todos array.
	// hack to use the good format for the date
	currentTodos.push({ ...options, ...{ date: date.toLocaleString() } })

	if (triggerSave) saveTodos()
	return true
}


// Handle the inputs on the options bar
[opts.inputTitle, opts.inputBody].forEach(input => input.addEventListener("keyup", (event: KeyboardEvent) => {
	if (event.key != "Enter") return

	const title = opts.inputTitle.value.trim()

	if (!addTodo({
		title,
		body: opts.inputBody.value,
		color: opts.inputColor.value,
		date: new Date()
	})) {
		// insertion failed, so we play a "pulse" animation
		optionsBar.classList.add("error")
		optionsBar.addEventListener("animationend", () =>
			optionsBar.classList.remove("error")
		)
		return
	}

	// insertion succeeded, so we reset the inputs and scroll up
	scrollTo(0, 0);
	[opts.inputTitle, opts.inputBody].forEach(e => e.value = "")
}))


// Remove all the selected todos
opts.delButton.addEventListener("click", () => {
	document.querySelectorAll(".todo.selected").forEach((e: HTMLDivElement) => {
		e.classList.add("remove")
		currentTodos.splice(parseInt(e.dataset.todoNumber), 1) // remove from the array
		// dont remove until "remove" animation ends
		e.addEventListener("animationend", () => {
			e.remove()
		})
	})
	saveTodos()
})


// Toggle the selected class of all the todos
opts.allButton.addEventListener("click", () => {
	const todos = document.querySelectorAll(".todo")
	for (let i = 0; i < todos.length; i++)
		setTimeout(() => todos[i].classList.toggle("selected"), i*(
			// if we have more than 50 todos, just dont do any fancy delaying
			todos.length < 50
			? 250/todos.length
			: 0
		))
})


/**
 * Save the current todos to the local storage
 */
function saveTodos() {
	localStorage.setItem("todos", JSON.stringify(currentTodos))
}


/**
 * Load the todos from the local storage and return them
 */
function getTodos(): TodoInfo[] {
	return JSON.parse(localStorage.getItem("todos")) || { }
}




// Insert the todos from the local storage
getTodos().forEach(options => addTodo(options))

// If we have no todos, add the default one
if (!Object.keys(currentTodos).length)
	addTodo({
		title: "Welcome to my Todos!",
		body: `So, yeah... This is a Todo! You can add more,
		remove them, and huhhh... That's pretty much it I guess.
		Oh yeah they get saved! (Well, unless you clear your cache or remove them)`
	})

// set up the "fancy" color picker
document.querySelectorAll(".color-picker").forEach((picker: HTMLDivElement) => {
	const input = picker.firstElementChild as HTMLInputElement
	const updateInput = () => picker.style.backgroundColor = input.value

	input.addEventListener("input", updateInput)
	updateInput()
})