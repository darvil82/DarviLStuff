const CAMOUNT = 10;
const CAMOUNT_HOVER = 5;


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
		if (state)
			e.classList.add("highlighted")
		else
			e.classList.remove("highlighted")
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
 * Populate the schedule with the subjects from the give object
 * @param {Object} dataObject - Object with the subject definitions:
 *
 * class-name: [name: string, color: array, teacher: string]
 * */
 function loadEntries(dataObject) {
	Object.entries(dataObject).forEach(item => {
		const entry = item[1];
		const clsName = item[0];
		const parsedColor = getColor(entry[1]);

		// Define the popup that will appear when clicking a subject
		const popup = () => {
			new Prompt(
				entry[0],
				`<b>Teacher:</b> ${entry[2]}.<br>
				<b>${countHours(clsName)}</b> hours per week.`,
				[
					new PromptButton("Volver", [
						parsedColor, getColor(darkenColor(entry[1], 10))
					])
				],
				false,
				parsedColor,
			).show()
		}

		document.querySelectorAll("."+clsName).forEach(element => {
			["mouseover", "focus"].forEach(listener => {
				element.addEventListener(listener, () => {
					hoverSubjects(clsName, entry[1])
				});
			});

			["mouseout", "blur"].forEach(listener => {
				element.addEventListener(listener, () => {
					hoverSubjects(clsName, entry[1], false)
				});
			});

			element.addEventListener("click", popup);
			element.addEventListener("keydown", event => {
				if (event.key == "Enter") popup()
			});

			element.innerText = entry[0];
			element.style.color = parsedColor;
			element.tabIndex = 0;
			hoverSubjects(clsName, entry[1], false)
		})
	})
}




/* Simplemente cambiar el fondo de forma aleatoria */
document.querySelector(".optbtn").addEventListener("click", () => {
	document.querySelector("body").style.backgroundImage =
	`url(https://picsum.photos/id/${parseInt(Math.random()*1000)}/1920/1080)`
});


/** Iliminar los subjects al pasar el cursor por encima de los días */
document.querySelectorAll(".top-header > .col-header").forEach((th, i) => {
	const subjects = document.querySelectorAll(
		`tr > [day="${i+1}"],
		 tr > td:nth-child(${i+2}):not([day])`
	);

	th.addEventListener("mouseover", () => {
		// aplicar clase a todos los elementos que pertenecen al día actual
		subjects.forEach(td => td.classList.add("lighten"))
	});

	th.addEventListener("mouseout", () => {
		// simplemente remover la clase a todos
		subjects.forEach(td => td.classList.remove("lighten"))
	});

	th.addEventListener("click", () => {
		showAlert(
			th.innerText,
			"<ul style='list-style-position: inside'><li>"
			+ Array.from(subjects)
				.map(e => e.innerText)	// obtener el nombre de los subjects
				.filter((v, i, a) => a.indexOf(v) == i)	// filtrar los repetidos
				.join("<li>")	// unir los nombres de los subjects
			+ "</ul>",
		)
	})
})




const ANIM_DELAY = 750;


/** Mostrar todos los subjects */
setTimeout(() => {
	const tds = document.querySelectorAll(".table-wrapper td");

	for (let i = 0; i < tds.length; i++) {
		setTimeout(() => {
			tds[i].classList.add("in");
		}, i*50);
	}
}, ANIM_DELAY);

/** Mostrar los ths */
setTimeout(() => {
	const ths = document.querySelectorAll(".row-header, .col-header");

	for (let i = 0; i < ths.length; i++) {
		setTimeout(() => {
			ths[i].classList.add("in");
		}, i*100);
	}
}, ANIM_DELAY + 250)
