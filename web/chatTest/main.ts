class Chat {
	constructor(public element: HTMLDivElement) { }

	addMessage(message: Message) {
		const msgElement = message.element
		this.element.appendChild(msgElement)

		// inmediately remove the node when it gets out of the chat
		new IntersectionObserver((entries, obs) => {
			if (!entries[0].isIntersecting) {
				msgElement.remove()
				obs.disconnect()
			}
		}, { root: this.element }).observe(msgElement)
	}

	clear() {
		this.element.innerHTML = ''
	}
}

class Message {
	private date: Date

	constructor(
		public user: string,
		public text: string,
		public userColor?: string,
		public isMentioned: boolean = false
	) {
		this.userColor = userColor ?? "white"
		this.date = new Date()
	}

	get element() {
		const element = document.importNode(messageTemplate, true).content.firstElementChild as HTMLElement;

		const usrEl = element.querySelector(".user") as HTMLSpanElement
		const textEl = element.querySelector(".body") as HTMLSpanElement
		const dateEl = element.querySelector(".timestamp") as HTMLSpanElement

		usrEl.textContent = this.user
		usrEl.style.color = this.userColor
		dateEl.textContent = getFormatHour(this.date)

		textEl.appendChild(Message.getParsedText(this.text))
		if (this.isMentioned) element.classList.add("mention")

		return element
	}

	static getParsedText(content: string): HTMLSpanElement {
		return parseEmotes(content)
	}
}

class Interval {
	private currentIntervalId: number

	constructor(public callback: (delay: number) => any) { }

	set(delay: number) {
		this.clear()
		this.currentIntervalId = setInterval(() => this.callback(delay), delay)
	}

	clear() {
		clearInterval(this.currentIntervalId)
	}
}

const messageTemplate = document.querySelector("[data-message-template]") as HTMLTemplateElement
const mainChat = new Chat(document.querySelector("[data-chat-main]"))
const mentionsChat = new Chat(document.querySelector("[data-chat-mentions]"))
const chatInput = document.querySelector("[data-chat-input]") as HTMLInputElement

// the user that will be mentioned in the messages
var userName = "darvil82"
var userColor = "rgb(0,255,100)"
const USERS = [
	"soulfulcomb",
	"quartrule",
	"painfulfounda",
	"loganberriesri",
	"scoffpolarbear",
	"knockbackbath",
	"passionlychnis",
	"squealingecono",
	"sighaxel",
	"swimmercorpus",
	"steelalter",
	"vanquishpatient",
	"sincecocksfoot",
	"hormonesbullo",
	"brewerblazerod",
	"wasteloyal",
	"factthere",
	"sadlydolphin",
	"knitsurfeit",
	"gesturepsych",
	"ferretideal",
	"finksnobby",
	"depictjoker",
	"losschild",
	"watchfulemiss",
	"conviction",
	"repelamerican",
	"nearcollected",
	"hoarsetaper",
	"calmadmirable",
	"pepsiincisive",
	"checkroad",
	"undresserect",
	"gapwretched",
	"tutorsqualid",
	"buttkick",
	"mallarrive",
	"cravecuff",
	"lapelspiteful",
	"vehiclenucleus",
	"stainedkoko",
	"alongsupreme",
	"honoredafter",
	"hauntfilm",
	"sordidjovial",
	"teambastion",
	"tuxedomittens",
	"handshakesailor",
	"sidelightopu",
	"porcupineout"
]
const MESSAGES = [
	"hey, how you doing",
	"lmao haha trolled :trollface:",
	"hey im very funny please give me attention",
	"okay so when are we playing something good",
	"LMAO :madman:",
	"hahahahha",
	"trolled :incredible:",
	"lol",
	"hey guys get free nitro here! https://dickord.com/gift",
	"how is that even possible :madman:",
	"okay what :sus:",
	"what the hell",
	"this is really cursed",
	"did you hydrate yourself? :madman:",
	"give me attention @!",
	"https://dikcok.com",
	"did you know that a whale is way bigger than me? :peter:",
	"okay so today I was trying to get a nap but you just started the fucking stream so I can't sleep",
	"gta8 map confirmed!",
	"jesus",
	"massive hole right there! :flushed:",
	"cringe",
	"goodbye!",
	"hello! :peter:",
	"what the actual fuck :sus:",
	"who gift me sub? thakns",
	"yoooooooooooooooooooooooooooooooooooooooooooooooooooooo",
	"hey can you please shut up? thanks",
	"hmmm nice :peter:",
	"why am I even here? I should be having breakfast and it's 2pm",
	"god someone please give @ the deserved shit",
	"@ @ @",
	"this chat fucking sucks",
	"check this nice link: http://yousuck.net",
	":peter_fall: :peter_fall: :peter_fall: :peter_fall:",
	"you looking good today :sunglasses:",
	"he is just very good :stuff:",
	":sus: :sus: :sus: :sus: :sus: :sus: :sus: :sus: :sus: :sus: :sus: :sus: :sus:",
	"wtf try to type !help",
	"testing if this works: <h1>hello</h1>",
]
const EMOTES = {
	peter: "peter.webp",
	sunglasses: "sunglasses.webp",
	stuff: "stuff.webp",
	trollface: "trollface.webp",
	madman: "madman.webp",
	flushed: "flushed.webp",
	incredible: "incredible.webp",
	sus: "sus.gif",
	peter_fall: "peter_fall.gif",
}
const CHAT_DELAY = 2000
const COMMANDS = {
	help: function() {
		sendKlydeMsg(`@ available commands: !${Object.keys(this).join(", !")}`)
	},
	emotes: () => {
		sendKlydeMsg(`@ heyy huhh this are the emotes :peter:: ${Object.keys(EMOTES).join(", ")}. Oh yeah for using them just type :emote:`)
	},
	name: () => {
		userName = prompt("change name to:").replaceAll(" ", "_") || userName
	},
	color: () => {
		userColor = prompt("change color to (CSS):", userColor) || userColor
	},
	delay: () => {
		const input = parseInt(prompt("change delay to (ms):", CHAT_DELAY.toString()))
		if (input == 0)
			randomMessagesInterval.clear()
		else
			randomMessagesInterval.set(input || CHAT_DELAY)
	},
	clear: () => {
		mainChat.clear()
		mentionsChat.clear()
	}
}


/**
 * Return a span element with all the emotes replaced with their respective
 * images while keeping the text
 */
function parseEmotes(text: string): HTMLSpanElement {
	const match = text.match(/:([a-zA-Z_]+):/g)
	const endEl = document.createElement("span")

	if (!match) {
		endEl.textContent = text
		return endEl
	}

	for (const emote of match) {
		const emoteName = emote.slice(1, -1)
		if (!EMOTES[emoteName]) continue

		const emoteImg = document.createElement("img")
		emoteImg.src = `./images/emotes/${EMOTES[emoteName]}`
		emoteImg.classList.add("emote")

		const textEl = document.createElement("span")
		const newContent = text.slice(0, text.indexOf(emote))
		if (newContent) {
			textEl.textContent = newContent
			endEl.appendChild(textEl)
		}
		endEl.appendChild(emoteImg)
		text = text.slice(text.indexOf(emote) + emote.length)
	}

	const lastText = document.createElement("span")
	lastText.textContent = text
	endEl.appendChild(lastText)

	return endEl
}


/**
 * Insert a message to the chat. If this has a mention in it, it may also be
 * inserted to the mentions chat.
 */
function insertMsg(
	user: string,
	content: string,
	userColor?: string,
	checkAt: boolean = true
) {
	const color = userColor ?? getRandomColor()
	const replacedText = content.replaceAll("@", `@${userName}`)
	let msg = new Message(user, content, color)

	if (checkAt && content.includes("@")) {
		msg.isMentioned = true
		msg.text = replacedText

		// append the same message unmentioned to the mentions chat
		mentionsChat.addMessage(new Message(user, replacedText, color))
	}
	mainChat.addMessage(msg)
}


/**
 * Insert a message to the chat using random content.
 */
function addRandomMsg() {
	const text = MESSAGES[randint(0, MESSAGES.length)]
	insertMsg(
		USERS[randint(0, USERS.length)],
		text
		+ (
			(randint(0, 20) == 0 && !text.includes("@")) ? " @" : ""
		) // add an extra @ at the end sometimes
	)
}


/**
 * Returns a random HSL color with maximum saturation and lightness.
 */
function getRandomColor() {
	return `hsl(${randint(0, 367)}, 100%, 50%)`
}

/**
 * Returns a random integer between min (inclusive) and max (exclusive).
 */
function randint(min: number, max: number) {
	return Math.floor(Math.random() * (max - min)) + min
}

/**
 * Returns the current hour in 24-hour format with proper prefix.
 */
function getFormatHour(date: Date): string {
	const hours = date.getHours()
	const minutes = date.getMinutes()
	return (
		((hours < 10) ? `0${hours}` : hours)
		+ ":"
		+ ((minutes < 10) ? `0${minutes}` : minutes)
	)
}

function sendKlydeMsg(msg: string) {
	insertMsg("klyde", msg, "lime")
}

var randomMessagesInterval = new Interval(d => {
	setTimeout(() => {
		addRandomMsg()
	}, Math.random() * d
	)
})
randomMessagesInterval.set(CHAT_DELAY)


// sets up the input field for handling user input
chatInput.addEventListener("keydown", e => {
	const inValue = chatInput.value.trim()
	if (e.key != "Enter" || inValue == "") return;
	chatInput.value = ""
	insertMsg(userName, inValue, userColor, false)

	// check if the message is a command
	if (inValue.startsWith("!")) {
		COMMANDS[inValue.slice(1)]?.()
	}
})

// adds random messages to the chat for populating it
{
	for (let i = 0; i < 25; i++)
		addRandomMsg()
}