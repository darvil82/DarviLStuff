const getTodoTemplate = () => document.importNode(
	document.querySelector("[data-todo-template]").content, true
).firstElementChild
const container = document.querySelector(".todos-container")
const input = document.querySelector("[data-input]")

const todos = []


function addTodo(title, body, color=null) {
	const todo = getTodoTemplate()
	if (color)
		todo.style.setProperty("--bg-color", color)
	todo.querySelector(".title").textContent = title
	todo.querySelector(".date").textContent = new Date().toLocaleString()
	todo.querySelector(".body").textContent = body
	container.append(todo)
	todos.push({
		title,
		body,
		color
	})
}


input.addEventListener("keyup", e => {
	if (e.key != "Enter") return
	addTodo(input.value)
	input.value = ""
})


addTodo("Testing", "balling")
