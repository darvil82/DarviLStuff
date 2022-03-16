function getTodoTemplate() {
    return document.importNode(
    // @ts-ignore
    document.querySelector("[data-todo-template]").content, true).firstElementChild;
}
const container = document.querySelector(".todos-container");
const optionsBar = document.querySelector(".options");
const opts = {
    inputTitle: document.querySelector("[data-input='title']"),
    inputBody: document.querySelector("[data-input='body']"),
    inputColor: document.querySelector("[data-input='color']"),
    delButton: document.querySelector("[data-input='remove']"),
    allButton: document.querySelector("[data-input='all']")
};
const currentTodos = {};
var AddTodoResult;
(function (AddTodoResult) {
    AddTodoResult[AddTodoResult["AlreadyExists"] = 0] = "AlreadyExists";
    AddTodoResult[AddTodoResult["InvalidName"] = 1] = "InvalidName";
})(AddTodoResult || (AddTodoResult = {}));
function addTodo(title, body = "", color, triggerSave = true) {
    if (!title)
        return AddTodoResult.InvalidName;
    if (currentTodos[title.toLowerCase()]) {
        console.error(`Todo '${title}' already exists.`);
        return AddTodoResult.AlreadyExists;
    }
    const todo = getTodoTemplate();
    // set all the content of the todo
    if (color)
        todo.style.setProperty("--bg-color", color);
    todo.querySelector(".title").textContent = title;
    todo.querySelector(".date").textContent = new Date().toLocaleString();
    todo.querySelector(".body").textContent = body;
    todo.dataset.todoName = title.toLowerCase();
    // add the click event to select it
    todo.addEventListener("click", () => todo.classList.toggle("selected"));
    // play the animation and remove it after .5s
    todo.classList.add("in");
    setTimeout(() => todo.classList.remove("in"), 500);
    // add the element to the container with all the todos
    container.prepend(todo);
    // save this todo data to the todos array
    currentTodos[title.toLowerCase()] = { title, body, color };
    if (triggerSave)
        saveTodos();
    return true;
}
document.addEventListener("keyup", (event) => {
    if (event.key != "Enter")
        return;
    switch (addTodo(opts.inputTitle.value, opts.inputBody.value, opts.inputColor.value)) {
        case AddTodoResult.AlreadyExists: {
            const elementMatch = document.querySelector(`[data-todo-name="${opts.inputTitle.value}"i]`);
            elementMatch.classList.add("selected");
            elementMatch.scrollIntoView();
        }
        case AddTodoResult.InvalidName: {
            optionsBar.classList.add("error");
            optionsBar.addEventListener("animationend", () => optionsBar.classList.remove("error"));
            break;
        }
        case true: {
            scrollTo(0, 0);
            [opts.inputTitle, opts.inputBody].forEach(e => e.value = "");
            return;
        }
    }
});
opts.delButton.addEventListener("click", () => {
    document.querySelectorAll(".todo.selected").forEach((e) => {
        e.classList.add("remove");
        delete currentTodos[e.dataset.todoName];
        e.addEventListener("animationend", () => {
            e.remove();
        });
    });
    saveTodos();
});
opts.allButton.addEventListener("click", () => {
    const todos = document.querySelectorAll(".todo");
    for (let i = 0; i < todos.length; i++)
        setTimeout(() => todos[i].classList.toggle("selected"), i * (
        // if we have more than 50 todos, just dont do any fancy delaying
        todos.length < 50
            ? 250 / todos.length
            : 0));
});
function saveTodos() {
    localStorage.setItem("todos", JSON.stringify(currentTodos));
}
function getTodos() {
    return JSON.parse(localStorage.getItem("todos")) || {};
}
Object.entries(getTodos()).forEach(([, { title, body, color }]) => addTodo(title, body, color));
if (!Object.keys(currentTodos).length)
    addTodo("Welcome to my Todos!", `So, yeah... This is a Todo! You can add more,
		remove them, and huhhh... That's pretty much it I guess.
		Oh yeah they get saved! (Well, unless you clear your cache or remove them)`);
//# sourceMappingURL=todo.js.map