const messageTemplate = document.querySelector("[data-message-template]") as HTMLTemplateElement
const mainChat = document.querySelector("[data-chat-main]") as HTMLDivElement
const mentionsChat = document.querySelector("[data-chat-mentions]") as HTMLDivElement
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
	"trolled",
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
	"massive hole right there!",
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

}





function appendMsgElement(message: Element, container: HTMLDivElement) {
	container.appendChild(message)

	new IntersectionObserver((entries, obv) => {
		if (!entries[0].isIntersecting) {
			message.remove()
			obv.disconnect()
		}
	}, { root: container }).observe(message)
}

function insertMsg(
	user: string,
	content: string,
	userColor?: string,
	checkAt: boolean = true
) {
	const msg = document.importNode(messageTemplate, true).content.firstElementChild as HTMLElement;

	const usrEl = msg.querySelector(".user") as HTMLSpanElement
	const textEl = msg.querySelector(".body") as HTMLSpanElement
	const dateEl = msg.querySelector(".timestamp") as HTMLSpanElement

	usrEl.textContent = user
	usrEl.style.color = userColor ? userColor : getRandomColor()
	dateEl.textContent = getFormatHour(new Date())


	if (content.includes("@") && checkAt) {
		textEl.textContent= content.replaceAll("@", `@${USER_NAME}`)
		msg.classList.add("mention")

		const clone = document.importNode(msg, true)
		clone.classList.remove("mention")
		appendMsgElement(clone, mentionsChat)
	} else
		textEl.textContent= content


	appendMsgElement(msg, mainChat)
}

function addRandomMsg() {
	const text = MESSAGES[randomBetween(0, MESSAGES.length)]
	insertMsg(
		USERS[randomBetween(0, USERS.length)],
		text
		+ (
			(randomBetween(0, 20) == 0 && !text.includes("@")) ? " @" : ""
		) // add an extra @ at the end sometimes
	)
}


function getRandomColor() {
	return `hsl(${Math.random() * 360}, 100%, 50%)`
}

function randomBetween(min: number, max: number) {
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
	}, Math.random() * 1000)
}, 2500)

chatInput.addEventListener("keydown", e => {
	if (e.key != "Enter" || chatInput.value == "") return;
	insertMsg(USER_NAME, chatInput.value, USER_COLOR, false)
	chatInput.value = ""
})

{
	for (let i = 0; i<25; i++)
		addRandomMsg()
}