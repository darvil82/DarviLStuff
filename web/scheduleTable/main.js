"use strict";

const CAMOUNT = 10;
const CAMOUNT_HOVER = 5;
const ANIM_DELAY = 750;


/**
 * Sets the state of the subjects
 * @param {string} classname - Name of the class of the subject
 * @param {number[]} colorArray - Color array to set ([R, G, B])
 * @param {boolean} state - State to set
 */
function hoverSubjects(classname, colorArray, state=true) {
	document.querySelectorAll("."+classname).forEach(e => {
		e.style.background = getColor(
			darkenColor(colorArray, (state ? CAMOUNT_HOVER : CAMOUNT)),
		);
		e.classList.toggle("highlighted", state)
	})
}

/**
 * Lowers the intensity of a color
 * @param {number[]} color - Color array ([R, G, B])
 * @param {number} amount - Value to lower
 * @returns {number[]} - Color array ([R, G, B])
 */
function darkenColor(color, value=20) {
	return color.map(v => parseInt(v/value + 30))
}

/**
 * Returns a color array as a CSS color sring
 * @param {number[]} color - Color array ([R, G, B])
 * @returns {string} - Color in CSS format
 */
function getColor(color) {
	return `rgb(${color.join(",")})`
}

/**
 * Counts the hours of a subject in the schedule
 * @param {string} classname - Name of the class of a subject
 * @returns {number} - Quantity of hours
 */
function countHours(classname) {
	let count = 0;
	document.querySelectorAll("."+classname).forEach(e => {
		count += e.rowSpan
	})
	return count
}

/**
 * Capitalizes the first letter of a string
 * @param {string} string The string to be parsed
 * @returns {string} The string with the first letter capitalized
 */
function capitalizeString(string) {
	return string[0].toUpperCase() + string.slice(1)
}

/**
 * Populate the schedule with the subjects from the give object
 * @param {Object} dataObject - Object with the subject definitions:
 *
 * class-name: [name: string, color: array, options: object]
 *
 * Each key-value pair of the options object will be shown when clicking the
 * subject.
 * */
function loadEntries(dataObject) {
	Object.entries(dataObject).forEach(item => {
		const [clsName, [name, color, extra]] = item;
		const parsedColor = getColor(color);

		// Define the popup that will appear when clicking a subject
		const popup = () => {
			new Prompt(
				name,
				(() => {
					let text = `<b>${countHours(clsName)}</b> hours per week.`;
					if (!extra)
						return text;
					for (let [key, value] of Object.entries(extra)) {
						text += `<br><b>${capitalizeString(key)}:</b> ${value}.`
					}
					return text
				})(),
				[
					new PromptButton("Ok", [
						parsedColor, getColor(darkenColor(color, 10))
					])
				],
				false,
				parsedColor,
			).show()
		}

		document.querySelectorAll("."+clsName).forEach(element => {
			["mouseover", "focus"].forEach(listener => {
				element.addEventListener(listener, () => {
					hoverSubjects(clsName, color)
				});
			});

			["mouseout", "blur"].forEach(listener => {
				element.addEventListener(listener, () => {
					hoverSubjects(clsName, color, false)
				});
			});

			element.addEventListener("click", popup);
			element.addEventListener("keydown", event => {
				if (event.key == "Enter") popup()
			});

			element.textContent = name;
			element.style.color = parsedColor;
			element.tabIndex = 0;
			hoverSubjects(clsName, color, false)
		})
	})
}




/* Just change the background to a random one when clicking the change bg button */
document.querySelector(".optbtn").addEventListener("click", () => {
	document.querySelector("body").style.backgroundImage =
	`url(https://picsum.photos/id/${parseInt(Math.random()*1000)}/1920/1080)`
});


/* Highlight the subjects when hovering over the days */
document.querySelectorAll(".top-header > .col-header").forEach((th, i) => {
	const subjects = document.querySelectorAll(
		`tr > [day="${i+1}"],
		 tr > td:nth-child(${i+2}):not([day])`
	);

	th.addEventListener("mouseover", () => {
		// apply class to all elements that belong to the current day
		subjects.forEach(td => td.classList.add("lighten"))
	});

	th.addEventListener("mouseout", () => {
		// simply remove the class from all elements
		subjects.forEach(td => td.classList.remove("lighten"))
	});

	th.addEventListener("click", () => {
		showAlert(
			th.textContent,
			"<ul style='list-style-position: inside'><li>"
			+ Array.from(subjects)
				.map(e => e.textContent)	// get the name of each subject
				.filter((v, i, a) => a.indexOf(v) == i)	// filter repeated
				.join("<li>")	// join all the subjects
			+ "</ul>",
		)
	})
})




/** Show all subjects */
setTimeout(() => {
	const tds = document.querySelectorAll(".table-wrapper td");

	for (let i = 0; i < tds.length; i++) {
		setTimeout(() => {
			tds[i].classList.add("in");
		}, i*50);
	}
}, ANIM_DELAY);

/** Show all ths */
setTimeout(() => {
	const ths = document.querySelectorAll(".row-header, .col-header");

	for (let i = 0; i < ths.length; i++) {
		setTimeout(() => {
			ths[i].classList.add("in");
		}, i*100);
	}
}, ANIM_DELAY + 250)
