/**
 * Create custom prompt windows that may contain text, buttons, and inputs.
 * Written by David Losantos.
 *
 * Wiki available at https://github.com/DarviL82/DarviLStuff/wiki/prompt.js
 */
"use strict";
var __spreadArrays = (this && this.__spreadArrays) || function () {
    for (var s = 0, i = 0, il = arguments.length; i < il; i++) s += arguments[i].length;
    for (var r = Array(s), k = 0, i = 0; i < il; i++)
        for (var a = arguments[i], j = 0, jl = a.length; j < jl; j++, k++)
            r[k] = a[j];
    return r;
};
(function () {
    // Get the stylesheet for the prompt and add it to the head
    var linkCSS = document.createElement("link");
    linkCSS.rel = "stylesheet";
    linkCSS.href = "https://darvil82.github.io/DarviLStuff/web/promptTest/prompt.css";
    document.querySelector("head").appendChild(linkCSS);
    // add the prompt elements to the body
    var container = document.createElement("div");
    container.className = "prompt-container";
    container.innerHTML = "\n\t\t<div class='prompt-window'>\n\t\t\t<div class='prompt-content'>\n\t\t\t\t<span class='prompt-header'></span>\n\t\t\t\t<p class='prompt-text'></p>\n\t\t\t</div>\n\t\t\t<div class='prompt-items'></div>\n\t\t</div>\n\t";
    document.querySelector("body").appendChild(container);
})();
// Constants pointing to the elements that we'll use.
var CONTAINER = document.querySelector('.prompt-container');
var WPROMPT = {
    header: document.querySelector('.prompt-header'),
    text: document.querySelector('.prompt-text'),
    items: document.querySelector(".prompt-items")
};
/**
 * Gets keyboard-focusable elements in the body
 * @param {HTMLElement} excludeParent - The element parent to exclude its children
 * @returns {HTMLElement[]} The array of elements
 */
function getKeyboardFocusableElements(excludeParent) {
    return __spreadArrays(document.querySelector("body").querySelectorAll('a[href], button, input, textarea, select, details, [tabindex]')).filter(function (el) { return !el.hasAttribute("disabled")
        && !el.getAttribute("aria-hidden")
        && !el.parentElement.isSameNode(excludeParent); });
}
var ELEMENTS_TAB_INDEX = { globalState: true };
/** Sets the tabIndex of all the elements in the DOM, except the ones inside the prompt container */
function setTabIndex(value) {
    if (value === void 0) { value = true; }
    var elements = getKeyboardFocusableElements(WPROMPT.items);
    if (value) {
        elements.forEach(function (e) { return e.tabIndex = ELEMENTS_TAB_INDEX[e]; });
        ELEMENTS_TAB_INDEX.globalState = true;
    }
    else if (ELEMENTS_TAB_INDEX.globalState) {
        elements.forEach(function (e) { return ELEMENTS_TAB_INDEX[e] = e.tabIndex; });
        elements.forEach(function (e) { return e.tabIndex = -1; });
        ELEMENTS_TAB_INDEX.globalState = false;
    }
}
/** A prompt window that may have some properties like text and items */
var Prompt = /** @class */ (function () {
    /**
     * @param {string} title - The title of the prompt
     * @param {string} body - The body of the prompt
     * @param {Array} itemsArray - An array of items to be displayed in the prompt
     * @param {boolean} vertical - Will the items be displayed vertically or horizontally?
     */
    function Prompt(title, body, itemsArray, vertical) {
        this.title = title || "";
        this.text = body || "";
        this.items = itemsArray || [new PromptButton("Ok")];
        this.isVertical = vertical || window.innerWidth < 600; // If the window is small, display the items vertically
    }
    /** Generate the prompt window with all the elements, and show it */
    Prompt.prototype.show = function () {
        var _this = this;
        WPROMPT.header.innerHTML = this.title;
        WPROMPT.text.innerHTML = this.text;
        WPROMPT.items.style.flexDirection = (this.isVertical) ? "column" : "row";
        // remove all the buttons and set the new ones
        Array.from(WPROMPT.items.children).forEach(function (e) { return WPROMPT.items.removeChild(e); });
        this.items.forEach(function (e) {
            WPROMPT.items.appendChild(e.genElement(_this.isVertical));
        });
        Prompt.display();
    };
    Object.defineProperty(Prompt, "isShown", {
        /** Return the state of the window */
        get: function () { return (CONTAINER.classList.contains("shown")); },
        enumerable: true,
        configurable: true
    });
    /** Shows the prompt window with the elements already added */
    Prompt.display = function () {
        CONTAINER.classList.add("shown");
        document.querySelector("body").style.overflowY = "hidden";
        setTabIndex(false);
    };
    /** Hides the prompt window */
    Prompt.hide = function () {
        CONTAINER.classList.remove("shown");
        document.querySelector("body").style.overflowY = "";
        setTabIndex(true);
    };
    Prompt.getNextItemID = function () { return "prompt-item-" + Prompt.itemCounter++; };
    Prompt.itemCounter = 0; // used to give each prompt item a unique ID
    return Prompt;
}());
/** A prompt button that can be pressed by the user.
 *  When the user presses it, the callback supplied will be called. */
var PromptButton = /** @class */ (function () {
    /**
     * @param {string} text - The text to display on the button
     * @param {Array} colorsArray - CSS colors to use for the gradient of the button background
     * @param {function} callback - The function to call when the button is pressed
     * @param {string} width - CSS width of the button
     * @param {boolean} closePromptOnPress - Will the prompt be closed when the button is pressed?
    **/
    function PromptButton(text, colorsArray, callback, width, closePromptOnPress) {
        if (colorsArray === void 0) { colorsArray = null; }
        if (callback === void 0) { callback = null; }
        if (width === void 0) { width = null; }
        if (closePromptOnPress === void 0) { closePromptOnPress = true; }
        this.text = text || "Button";
        this.colors = colorsArray || [];
        this.callback = callback || (function () { });
        this.width = width || "";
        this.closePromptOnPress = closePromptOnPress;
    }
    /** Return the HTML element with the properties specified */
    PromptButton.prototype.genElement = function () {
        var _this = this;
        var b = document.createElement("button");
        b.style.backgroundImage = "linear-gradient(180deg, " + this.colors.toString() + ")";
        b.innerHTML = this.text;
        b.style.width = this.width;
        b.addEventListener("click", function () { return _this.press(); });
        return b;
    };
    /** Call the callback function and hide the prompt if the closePromptOnPress property is true */
    PromptButton.prototype.press = function () {
        if (this.closePromptOnPress)
            Prompt.hide();
        this.callback();
    };
    return PromptButton;
}());
/** A prompt input that lets the user enter text.
 *  The value entered can be obtained through the `value` property. */
var PromptInput = /** @class */ (function () {
    /**
     * @param {string} placeholder - The placeholder text to display in the input
     * @param {string} defaultText - The default text value inside the input
     * @param {string} width - CSS width of the input box
     * @param {function} callback - The function to call with the value when the Enter key is pressed
     */
    function PromptInput(placeholder, defaultText, width, callback) {
        this.placeholder = placeholder || "";
        this.defaultText = defaultText || "";
        this.width = width || "100%";
        this.callback = callback || (function () { });
        this.id = Prompt.getNextItemID();
    }
    PromptInput.prototype.genElement = function () {
        var _this = this;
        var i = document.createElement("input");
        i.placeholder = this.placeholder;
        i.id = this.id;
        i.value = this.defaultText;
        i.style.width = this.width;
        i.addEventListener("keydown", function (e) {
            if (e.key == "Enter")
                _this.callback(_this.value);
        });
        return i;
    };
    Object.defineProperty(PromptInput.prototype, "element", {
        get: function () { return document.getElementById(this.id); },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PromptInput.prototype, "value", {
        /** Return the value entered by the user */
        get: function () { return this.element.value; },
        enumerable: true,
        configurable: true
    });
    return PromptInput;
}());
/** A prompt input that lets the user select an option from a list of options.
 *  The value entered can be obtained through the `value` property, and the index
 *  of it in the options array with the `index` property. */
var PromptOptionList = /** @class */ (function () {
    /**
     * @param {Array} optList - An array of options (strings) to display in the list
     * @param {string} selectedIndex - The index of the selected option by default. Default value is 0.
     * @param {string} width - CSS width of the input box
     * @param {function} callback - The function to call with the value and index when the value is changed
    */
    function PromptOptionList(optList, selectedIndex, width, callback) {
        this.optList = optList;
        this.selectedIndex = selectedIndex || 0;
        this.width = width || "";
        this.callback = callback || (function () { });
        this.id = Prompt.getNextItemID();
    }
    PromptOptionList.prototype.genElement = function () {
        var _this = this;
        var i = document.createElement("select");
        i.id = this.id;
        i.style.width = this.width;
        PromptOptionList.getOptionElements(this.optList).forEach(function (e) {
            if (_this.selectedIndex == _this.optList.indexOf(e.innerHTML))
                e.selected = true;
            i.appendChild(e);
        });
        i.addEventListener("change", function () { return _this.callback(_this.value, _this.index); });
        return i;
    };
    Object.defineProperty(PromptOptionList.prototype, "element", {
        get: function () { return document.getElementById(this.id); },
        enumerable: true,
        configurable: true
    });
    /** Return the option elements from the options array */
    PromptOptionList.getOptionElements = function (optList) {
        return __spreadArrays(optList.map(function (opt) {
            var e = document.createElement("option");
            e.innerHTML = opt;
            return e;
        }));
    };
    Object.defineProperty(PromptOptionList.prototype, "value", {
        /** Return the value entered by the user */
        get: function () { return this.element.value; },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PromptOptionList.prototype, "index", {
        /** Return the index of the selected option on the options */
        get: function () { return this.element.selectedIndex; },
        enumerable: true,
        configurable: true
    });
    return PromptOptionList;
}());
/** A prompt spacer that basically just adds a little
 *  space between the prompt items. */
var PromptSpacer = /** @class */ (function () {
    /**
     * @param {string} width - The CSS width of the spacer
     * @param {string} shapeWidth - The CSS width of the spacer shape
     * @param {string} shapeColor - The CSS color of the spacer shape
     */
    function PromptSpacer(width, shapeWidth, shapeColor) {
        this.width = PromptSpacer.getWidth(width) || "0";
        this.shapeWidth = shapeWidth || "0";
        this.shapeColor = shapeColor || "#1f1f1f";
    }
    PromptSpacer.getWidth = function (width) {
        if (!width)
            return 0;
        if (width.startsWith("-")) {
            return 0;
        }
        return width;
    };
    PromptSpacer.prototype.genElement = function (isVertical) {
        var div = document.createElement("div");
        if (isVertical) {
            div.style.marginBlock = this.width;
            div.style.height = this.shapeWidth;
        }
        else {
            div.style.marginInline = this.width;
            div.style.width = this.shapeWidth;
        }
        div.style.backgroundColor = this.shapeColor;
        return div;
    };
    return PromptSpacer;
}());
// Easy to use functions like the alert() and prompt() built-ins.
/** A prompt window that will display a message to the user.
 * @param {string} title - The title of the prompt
 * @param {string} body - The body of the prompt
 */
function showAlert(title, body) {
    new Prompt(title, body, [new PromptButton("Ok")]).show();
}
/** A prompt window that will ask the user to input a value.
 * @param {string} title - The title of the prompt
 * @param {string} body - The body of the prompt
 * @param {function} callback - The function to call with the value of the input when the user presses the OK button
 * @param {string} defaultValue - The default value of the input
 */
function showPrompt(title, body, callback, defaultValue) {
    if (defaultValue === void 0) { defaultValue = null; }
    var inputText = new PromptInput(null, defaultValue, null, function () { return okButton.press(); });
    var okButton = new PromptButton("Ok", ["lime", "green"], function () { callback(inputText.value); });
    new Prompt(title, body, [
        inputText,
        new PromptSpacer(),
        new PromptButton("Cancel"),
        okButton
    ]).show();
}
/** A prompt window that will ask the user to select the Ok or Cancel button.
 * @param {string} title - The title of the prompt
 * @param {string} body - The body of the prompt
 * @param {function} okCallback - The function to call when the user presses the OK button
 * @param {function} cancelCallback - The function to call when the user presses the Cancel button
 */
function showConfirm(title, body, okCallback, cancelCallback) {
    if (cancelCallback === void 0) { cancelCallback = null; }
    new Prompt(title, body, [
        new PromptButton("Cancel", ["red", "darkred"], cancelCallback),
        new PromptButton("Ok", ["lime", "green"], okCallback)
    ]).show();
}
