class Chat {
    constructor(element) {
        this.element = element;
    }
    addMessage(message) {
        const msgElement = message.element;
        this.element.appendChild(msgElement);
        new IntersectionObserver((entries, obs) => {
            if (!entries[0].isIntersecting) {
                msgElement.remove();
                obs.disconnect();
            }
        }, { root: this.element }).observe(msgElement);
    }
}
class Message {
    constructor(user, text, userColor, isMentioned = false) {
        this.user = user;
        this.text = text;
        this.userColor = userColor;
        this.isMentioned = isMentioned;
        this.userColor = userColor ?? "white";
        this.date = new Date();
    }
    get element() {
        const element = document.importNode(messageTemplate, true).content.firstElementChild;
        const usrEl = element.querySelector(".user");
        const textEl = element.querySelector(".body");
        const dateEl = element.querySelector(".timestamp");
        usrEl.textContent = this.user;
        usrEl.style.color = this.userColor;
        dateEl.textContent = getFormatHour(this.date);
        textEl.appendChild(Message.getParsedText(this.text));
        if (this.isMentioned)
            element.classList.add("mention");
        return element;
    }
    static getParsedText(content) {
        return parseEmotes(content);
    }
}
const messageTemplate = document.querySelector("[data-message-template]");
const mainChat = new Chat(document.querySelector("[data-chat-main]"));
const mentionsChat = new Chat(document.querySelector("[data-chat-mentions]"));
const chatInput = document.querySelector("[data-chat-input]");
const USER_NAME = "darvil82";
const USER_COLOR = "rgb(0,255,100)";
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
];
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
    "wtf guys try to type !emotes",
    "testing if this works: <h1>hello</h1>",
];
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
};
/**
 * Return a span element with all the emotes replaced with their images while keeping the text
 */
function parseEmotes(text) {
    const match = text.match(/:([a-zA-Z_]+):/g);
    const endEl = document.createElement("span");
    if (!match) {
        endEl.textContent = text;
        return endEl;
    }
    for (const emote of match) {
        const emoteName = emote.slice(1, -1);
        if (!EMOTES[emoteName])
            continue;
        const emoteImg = document.createElement("img");
        emoteImg.src = `./images/emotes/${EMOTES[emoteName]}`;
        emoteImg.classList.add("emote");
        const textEl = document.createElement("span");
        textEl.textContent = text.slice(0, text.indexOf(emote));
        endEl.appendChild(textEl);
        endEl.appendChild(emoteImg);
        text = text.slice(text.indexOf(emote) + emote.length);
    }
    const lastText = document.createElement("span");
    lastText.textContent = text;
    endEl.appendChild(lastText);
    return endEl;
}
function insertMsg(user, content, userColor, checkAt = true) {
    const color = userColor ?? getRandomColor();
    const replacedText = content.replaceAll("@", `@${USER_NAME}`);
    let msg = new Message(user, content, color);
    if (checkAt && content.includes("@")) {
        msg.isMentioned = true;
        msg.text = replacedText;
        // append the same message unmentioned to the mentions chat
        mentionsChat.addMessage(new Message(user, replacedText, color));
    }
    mainChat.addMessage(msg);
}
function addRandomMsg() {
    const text = MESSAGES[randint(0, MESSAGES.length)];
    insertMsg(USERS[randint(0, USERS.length)], text
        + ((randint(0, 20) == 0 && !text.includes("@")) ? " @" : "") // add an extra @ at the end sometimes
    );
}
function getRandomColor() {
    return `hsl(${randint(0, 367)}, 100%, 50%)`;
}
function randint(min, max) {
    return Math.floor(Math.random() * (max - min)) + min;
}
function getFormatHour(date) {
    const hours = date.getHours();
    const minutes = date.getMinutes();
    return (((hours < 10) ? `0${hours}` : hours)
        + ":"
        + ((minutes < 10) ? `0${minutes}` : minutes));
}
setInterval(() => {
    setTimeout(() => {
        addRandomMsg();
    }, Math.random() * 3000);
}, 1500);
chatInput.addEventListener("keydown", e => {
    const inValue = chatInput.value;
    if (e.key != "Enter" || inValue == "")
        return;
    chatInput.value = "";
    if (inValue == "!emotes") {
        insertMsg("klyde", `@ heyy huhh this are the emotes :peter:: ${Object.keys(EMOTES).join(", ")}`, "lime");
        return;
    }
    insertMsg(USER_NAME, inValue, USER_COLOR, false);
});
{
    for (let i = 0; i < 25; i++)
        addRandomMsg();
}
//# sourceMappingURL=main.js.map