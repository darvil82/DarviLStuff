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
const defaultOptions = {
    title: "",
    body: "",
    date: new Date(),
    color: "#00CED1",
};
/**
 * All the todos that we have in the container
 */
const currentTodos = [];
class Todo {
    element;
    _options; // this needs to be private because options should only be changed by the update method
    isEditing = false;
    constructor(options) {
        this.element = getTodoTemplate();
        this.show();
        this.setEvents();
        this.element.tabIndex = 0;
        this.update({ ...defaultOptions, ...options });
        currentTodos.push(this);
        saveTodos();
    }
    /**
     * Update the todo with the given options
     */
    update(options) {
        Object.entries(options)
            .forEach(function ([key, value]) { this[key] = value; }, this);
        this._options = { ...this._options, ...options };
        saveTodos();
    }
    /**
     * Set the events for the todo
     */
    setEvents() {
        this.element.addEventListener("click", this.toggleSelect.bind(this));
        this.element.addEventListener("dblclick", this.toggleEdit.bind(this));
        document.addEventListener("keyup", function (event) {
            if ((event.target === this.element.querySelector(".title")
                || event.target === this.element.querySelector(".body"))
                && event.key === "Enter")
                this.toggleEdit();
        }.bind(this));
    }
    /**
     * Remove the todo
     */
    remove() {
        this.element.classList.add("remove");
        currentTodos.splice(currentTodos.indexOf(this), 1);
        // dont remove until "remove" animation ends
        this.element.addEventListener("animationend", () => this.element.remove());
    }
    /**
     * Toggle the todo editing mode
     */
    toggleEdit() {
        // remove the selected class
        this.element.classList.remove("selected");
        if (this.isEditing) {
            if (!this.updateFromElements())
                return;
        }
        this.element.classList.toggle("edit", !this.isEditing);
        this.element.querySelectorAll(".title, .body")
            .forEach(e => e.contentEditable = this.isEditing ? "false" : "true");
        this.isEditing = !this.isEditing;
    }
    /**
     * Toggle the todo selection
     */
    toggleSelect() {
        if (this.isEditing)
            return;
        this.element.classList.toggle("selected");
    }
    /**
     * Show the todo in the container
     */
    show() {
        // play the animation and remove it after .5s
        this.element.classList.add("in");
        setTimeout(() => this.element.classList.remove("in"), 500);
        // add the element to the container with all the todos
        container.prepend(this.element);
    }
    /**
     * Update the todo using the data from the elements in it
     */
    updateFromElements() {
        const title = this.element.querySelector(".title").textContent.trim();
        if (!title) {
            this.shake();
            return false;
        }
        this.update({
            title,
            body: this.element.querySelector(".body").textContent,
            color: this.element.querySelector(".color-btn").value
        });
        return true;
    }
    shake() {
        this.element.classList.add("shake");
        this.element.addEventListener("animationend", () => this.element.classList.remove("shake"));
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
        if (!color.startsWith("#"))
            throw new Error("Color must be in hex format");
        this.element.style.setProperty("--bg-color", color);
        this.element.querySelector(".color-btn").value = color;
    }
    // -------------------- Getters --------------------
    get isSelected() {
        return this.element.classList.contains("selected");
    }
    get options() {
        // we need to make sure we save the date in the great format... Ugly!
        return { ...this._options, ...{ date: this._options.date.toLocaleString() } };
    }
}
/**
 * Inserts a Todo into the container
 * @param options The options of the Todo
 */
function addTodo(options) {
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
    currentTodos.reverse().forEach((todo, i) => {
        setTimeout(() => todo.toggleSelect(), i * (
        // if we have more than 25 todos, just dont do any fancy delaying
        currentTodos.length < 25
            ? 250 / currentTodos.length
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
    return JSON.parse(localStorage.getItem("todos")) || [];
}
// Insert the todos from the local storage
getTodos().forEach(options => addTodo(options));
// If we have no todos, add the default one
if (!currentTodos.length) {
    addTodo({
        title: "Another note",
        body: `Adding a todo is simple! Just type the contents up there and press enter.
		Editing them? Even easier! Just double click on any todo to enable the edit mode.
		Once finished, double click again!`,
        color: "#483cb5",
    });
    addTodo({
        title: "Welcome to my Todos!",
        body: `So, yeah... This is a Todo! You can add,
		remove, and edit them! That's pretty much it I guess...
		Oh yeah they get saved! (Well, unless you clear your cache or remove them)`
    });
}
// set up the "fancy" color picker
document.querySelectorAll(".color-picker").forEach((picker) => {
    const input = picker.firstElementChild;
    const updateInput = () => picker.style.backgroundColor = input.value;
    input.addEventListener("input", updateInput);
    updateInput();
});
//# sourceMappingURL=todo.js.map