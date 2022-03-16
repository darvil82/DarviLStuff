const getTodoTemplate = () => document.importNode(
	document.querySelector("[data-todo-template]").content, true
).firstElementChild
const container = document.querySelector(".todos-container")
const optionsBar = document.querySelector(".options")
const inputTitle = document.querySelector("[data-input-title]")
const inputBody = document.querySelector("[data-input-body]")
const inputColor = document.querySelector("[data-input-color]")
const delButton = document.querySelector("[data-input-remove]")
const allButton = document.querySelector("[data-input-all]")

const todos = {}


function addTodo(title, body, color=null) {
	if (!title) return;

	if (todos[title.toLowerCase()]) {
		console.error(`Todo '${title}' already exists.`)
		return false
	}

	const todo = getTodoTemplate()

	// set all the content of the todo
	if (color) todo.style.setProperty("--bg-color", color)
	todo.querySelector(".title").textContent = title
	todo.querySelector(".date").textContent = new Date().toLocaleString()
	todo.querySelector(".body").textContent = body
	todo.dataset.todoName = title

	// add the click event to select it
	todo.addEventListener("click", () => todo.classList.toggle("selected"))

	// play the animation and remove it after .5s
	todo.classList.add("in")
	setTimeout(() => todo.classList.remove("in"), 500)

	// add the element to the container with all the todos
	container.prepend(todo)

	// save this todo data to the todos array
	todos[title.toLowerCase()] = { title, body, color }
	return true
}


inputTitle.addEventListener("keyup", e => {
	if (e.key != "Enter") return

	if (addTodo(inputTitle.value, inputBody.value, inputColor.value)) {
		scrollTo(0, 0)
		inputTitle.value = ""
		return
	}

	optionsBar.classList.add("error")
	optionsBar.addEventListener("animationend", () =>
		optionsBar.classList.remove("error")
	)
	const elementMatch = document.querySelector(
		`[data-todo-name="${inputTitle.value}"i]`
	)
		elementMatch.classList.add("selected")
		elementMatch.scrollIntoView()

})

delButton.addEventListener("click", () => {
	document.querySelectorAll(".todo.selected").forEach(e => {
		e.classList.add("remove")
		e.addEventListener("animationend", () => {
			delete todos[e.dataset.todoName]
			e.remove()
		})
	})
})

allButton.addEventListener("click", () => {
	const todos = document.querySelectorAll(".todo")
	for (let i = 0; i < todos.length; i++)
		setTimeout(() => todos[i].classList.toggle("selected"), i*(
			// if we have more than 50 todos, just dont do any fancy delaying
			todos.length < 50
			? 250/todos.length
			: 0
		))
})


for (let x = 0; x < 7; x++)
addTodo(`Todo test ${x}`, "Lorem ipsum dolor sit, amet consectetur adipisicing elit. A, nam.")
