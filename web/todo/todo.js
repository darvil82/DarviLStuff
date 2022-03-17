/**
 * Get the template of a Todo
 */
function getTodoTemplate() {
    return document.importNode(
    // @ts-ignore
    document.querySelector("[data-todo-template]").content, true).firstElementChild;
}
// The container which holds all the todos
const container = document.querySelector(".todos-container");
// Options bar and it's inputs/buttons (opts)
const optionsBar = document.querySelector(".options");
const opts = {
    inputTitle: document.querySelector("[data-input='title']"),
    inputBody: document.querySelector("[data-input='body']"),
    inputColor: document.querySelector("[data-input='color']"),
    delButton: document.querySelector("[data-input='remove']"),
    allButton: document.querySelector("[data-input='all']")
};
[];
/**
 * All the todos that we have in the container
 */
const currentTodos = [];
class Todo {
    constructor(options) {
        this.isEditing = false;
        this.element = getTodoTemplate();
        this.update(options);
        this.show();
        this.setEvents();
        this.element.tabIndex = 0;
        this.save();
    }
    update(options) {
        Object.entries(options).forEach(function ([key, value]) { this[key] = value; }, this);
        this._options = options;
    }
    remove() {
        this.element.classList.add("remove");
        currentTodos.splice(currentTodos.indexOf(this), 1);
        // dont remove until "remove" animation ends
        this.element.addEventListener("animationend", () => this.element.remove());
    }
    edit() {
        // remove the selected class
        this.element.classList.remove("selected");
        // add the edit class
        this.element.classList.toggle("edit");
        this.isEditing = !this.isEditing;
    }
    select() {
        console.log(this);
        if (this.isEditing)
            return;
        this.element.classList.toggle("selected");
    }
    setEvents() {
        this.element.addEventListener("click", this.select.bind(this));
        this.element.addEventListener("dblclick", this.edit.bind(this));
        this.element.querySelector(".save-btn")
            .addEventListener("click", this.save.bind(this));
    }
    show() {
        // play the animation and remove it after .5s
        this.element.classList.add("in");
        setTimeout(() => this.element.classList.remove("in"), 500);
        // add the element to the container with all the todos
        container.prepend(this.element);
    }
    save() {
        // save this todo data to the todos array.
        currentTodos.push(this);
        saveTodos();
    }
    // -------------------- Setters --------------------
    set title(content) {
        this.element.querySelector(".title").textContent = content.trim();
    }
    set body(content) {
        this.element.querySelector(".body").textContent = content.trim();
    }
    set date(date) {
        this.element.querySelector(".date").textContent = date.toLocaleString();
    }
    set color(color) {
        this.element.style.setProperty("--bg-color", color);
    }
    // -------------------------------------------------
    get isSelected() {
        return this.element.classList.contains("selected");
    }
    get options() {
        return this._options;
    }
}
/**
 * Inserts a Todo into the container
 * @param options The options of the Todo
 * @param triggerSave Automatically save the todos after inserting
 */
function addTodo(options, triggerSave = true) {
    if (!options.title.trim())
        return false;
    new Todo(options);
    return true;
}
// Handle the inputs on the options bar
[opts.inputTitle, opts.inputBody].forEach(input => input.addEventListener("keyup", (event) => {
    if (event.key != "Enter")
        return;
    const title = opts.inputTitle.value.trim();
    if (!addTodo({
        title,
        body: opts.inputBody.value,
        color: opts.inputColor.value,
        date: new Date()
    })) {
        // insertion failed, so we play a "pulse" animation
        optionsBar.classList.add("error");
        optionsBar.addEventListener("animationend", () => optionsBar.classList.remove("error"));
        return;
    }
    // insertion succeeded, so we reset the inputs and scroll up
    scrollTo(0, 0);
    [opts.inputTitle, opts.inputBody].forEach(e => e.value = "");
}));
// Remove all the selected todos
opts.delButton.addEventListener("click", () => {
    currentTodos.filter(t => t.isSelected).forEach(t => t.remove());
    saveTodos();
});
// Toggle the selected class of all the todos
opts.allButton.addEventListener("click", () => {
    const todos = currentTodos;
    todos.forEach((todo, i) => {
        setTimeout(() => todo.select(), i * (
        // if we have more than 25 todos, just dont do any fancy delaying
        todos.length < 25
            ? 250 / todos.length
            : 0));
    });
});
/**
 * Save the current todos to the local storage
 */
function saveTodos() {
    localStorage.setItem("todos", JSON.stringify(currentTodos.map(t => t.options)));
}
/**
 * Load the todos from the local storage and return them
 */
function getTodos() {
    return JSON.parse(localStorage.getItem("todos"));
}
// Insert the todos from the local storage
getTodos().forEach(options => addTodo(options));
// If we have no todos, add the default one
if (!currentTodos.length)
    addTodo({
        title: "Welcome to my Todos!",
        body: `So, yeah... This is a Todo! You can add more,
		remove them, and huhhh... That's pretty much it I guess.
		Oh yeah they get saved! (Well, unless you clear your cache or remove them)`
    });
// set up the "fancy" color picker
document.querySelectorAll(".color-picker").forEach((picker) => {
    const input = picker.firstElementChild;
    const updateInput = () => picker.style.backgroundColor = input.value;
    input.addEventListener("input", updateInput);
    updateInput();
});
//# sourceMappingURL=todo.js.map