class Chat {
	constructor(public element: HTMLDivElement) {}

	addMessage(message: Message) {
		const msgElement = message.element
		this.element.appendChild(msgElement)

		new IntersectionObserver((entries, obs) => {
			if (!entries[0].isIntersecting) {
				msgElement.remove()
				obs.disconnect()
			}
		}, { root: this.element }).observe(msgElement)
	}
}

class Message {
	constructor(
		public user: string,
		public text: string,
		public userColor?: string,
		public isMentioned: boolean = false
	) {
		this.userColor = userColor || "white"
	}

	get element() {
		const element = document.importNode(messageTemplate, true).content.firstElementChild as HTMLElement;

		const usrEl = element.querySelector(".user") as HTMLSpanElement
		const textEl = element.querySelector(".body") as HTMLSpanElement
		const dateEl = element.querySelector(".timestamp") as HTMLSpanElement

		usrEl.textContent = this.user
		usrEl.style.color = this.userColor
		dateEl.textContent = getFormatHour(new Date())

		textEl.appendChild(Message.getParsedContent(this.text))
		if (this.isMentioned) element.classList.add("mention")

		return element
	}

	static getParsedContent(content: string): HTMLSpanElement {
		const span = document.createElement("span")
		span.appendChild(parseEmotes(content))

		return span
	}
}

const messageTemplate = document.querySelector("[data-message-template]") as HTMLTemplateElement
const mainChat = new Chat(document.querySelector("[data-chat-main]"))
const mentionsChat =  new Chat(document.querySelector("[data-chat-mentions]"))
const chatInput = document.querySelector("[data-chat-input]") as HTMLInputElement

const USER_NAME = "darvil82"
const USER_COLOR = "rgb(0,255,100)"
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
	"wifeshop",
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
	"lmao haha trolled",
	"hey im very funny please give me attention",
	"okay so when are we playing something good",
	"LMAO",
	"hahahahha",
	"trolled :incredible:",
	"lol",
	"hey guys get free nitro here! https://dickord.com/gift",
	"how is that even possible LOL",
	"okay what",
	"what the hell",
	"this is really cursed",
	"did you hydrate yourself?",
	"give me attention @",
	"https://dikcok.com",
	"did you know that a whale is way bigger than me?",
	"okay so today I was trying to get a nap but you just started the fucking stream so I can't sleep",
	"gta8 map confirmed!",
	"jesus",
	"massive hole right there! :flushed:",
	"cringe",
	"goodbye!",
	"hello!",
	"what the actual fuck",
	"who gift me sub? thakns",
	"yoooooooooooooooooooooooooooooooooooooooooooooooooooooo",
	"hey can you please shut up? thanks",
	"hmmm nice",
	"why am I even here? I should be having breakfast and it's 2pm",
	"god some please give @ the deserved shit",
	"@ @ @",
	"this chat fucking sucks",
	"check this nice link: http://yousuck.net"
]
const EMOTES = {
	incredible: "incredible.webp",
	flushed: "flushed.webp",
}


function parseEmotes(text: string): HTMLSpanElement {
	const pattern = /:([a-zA-Z_]+):/g
	const match = text.match(pattern)
	const endEl = document.createElement("span")

	if (!match) {
		endEl.textContent = text
		return endEl
	}

	match.forEach(emote => {
		const emoteName = emote.slice(1, -1)
		const emoteEl = document.createElement("img")
		emoteEl.src = `./images/emotes/${EMOTES[emoteName]}`
		emoteEl.classList.add("emote")
		endEl.appendChild(emoteEl)
	})

	return endEl
}


function insertMsg(
	user: string,
	content: string,
	userColor?: string,
	checkAt: boolean = true
) {
	let msg = new Message(user, content, userColor || getRandomColor())
	if (checkAt && content.includes("@")) {
		msg.isMentioned = true

		mentionsChat.addMessage(msg)
	}
	mainChat.addMessage(msg)
}




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


function getRandomColor() {
	return `hsl(${randint(0, 367)}, 100%, 50%)`
}

function randint(min: number, max: number) {
	return Math.floor(Math.random() * (max - min)) + min
}

function getFormatHour(date: Date): string {
	const hours = date.getHours()
	const minutes = date.getMinutes()
	return (
		((hours < 10) ? `0${hours}` : hours)
		+ ":"
		+ ( (minutes < 10) ? `0${minutes}` : minutes)
	)
}


setInterval(() => {
	setTimeout(() => {
		addRandomMsg()
	}, Math.random() * 3000)
}, 1000)

chatInput.addEventListener("keydown", e => {
	if (e.key != "Enter" || chatInput.value == "") return;
	insertMsg(USER_NAME, chatInput.value, USER_COLOR, false)
	chatInput.value = ""
})

{
	for (let i = 0; i<25; i++)
		addRandomMsg()
}