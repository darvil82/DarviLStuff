const messageTemplate = document.querySelector("[data-message-template]");
const mainChat = document.querySelector("[data-chat-main]");
const mentionsChat = document.querySelector("[data-chat-mentions]");
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
];
const MESSAGES = [
    "hey, how you doing",
    "lmao haha trolled",
    "hey im very funny please give me attention",
    "okay so when are we playing something good",
    "LMAO",
    "hahahahha",
    "trolled",
    "lol",
    "hey guys get free nitro here! <span class='fakelink'>dickord.com/gift</span>",
    "how is that even possible LOL",
    "okay what",
    "what the hell",
    "this is really cursed",
    "did you hydrate yourself?",
    "give me attention @",
    "<span class='fakelink'>dikcok.com</span>",
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
    "check this nice link: <span class='fakelink'>yousuck.net</span>"
];
function appendMsgElement(message, container) {
    container.appendChild(message);
    if (container.childElementCount > 20)
        container.firstElementChild.remove();
}
function insertMsg(user, content, userColor, checkAt = true) {
    const msg = document.importNode(messageTemplate.content, true);
    const date = new Date();
    const usrEl = msg.querySelector(".user");
    const textEl = msg.querySelector(".body");
    const dateEl = msg.querySelector(".timestamp");
    usrEl.textContent = user;
    usrEl.style.color = userColor ? userColor : getRandomColor();
    dateEl.textContent = getFormatHour(date);
    if (content.includes("@") && checkAt) {
        textEl.innerHTML = content.replaceAll("@", `@${USER_NAME}`);
        /** Create a clone of the node because otherwise we would use the same
         *  reference to the node both times */
        const mentionChatNode = document.importNode(msg, true);
        msg.firstElementChild.classList.add("mention");
        appendMsgElement(mentionChatNode, mentionsChat);
    }
    else
        textEl.innerHTML = content;
    appendMsgElement(msg, mainChat);
}
function addRandomMsg() {
    const text = MESSAGES[randomBetween(0, MESSAGES.length)];
    insertMsg(USERS[randomBetween(0, USERS.length)], text
        + ((randomBetween(0, 20) == 0 && !text.includes("@")) ? " @" : "") // add an extra @ at the end sometimes
    );
}
function getRandomColor() {
    return `hsl(${Math.random() * 360}, 100%, 50%)`;
}
function randomBetween(min, max) {
    return Math.floor(Math.random() * (max - min)) + min;
}
function getFormatHour(date) {
    const hours = date.getHours();
    const minutes = date.getMinutes();
    return (((hours < 10) ? `${hours}0` : hours)
        + ":"
        + ((minutes < 10) ? `${minutes}0` : minutes));
}
setInterval(() => {
    setTimeout(() => {
        addRandomMsg();
    }, Math.random() * 1000);
}, 2000);
chatInput.addEventListener("keydown", e => {
    if (e.key != "Enter" || chatInput.value == "")
        return;
    insertMsg(USER_NAME, chatInput.value, USER_COLOR, false);
    chatInput.value = "";
});
{
    for (let i = 0; i < 25; i++)
        addRandomMsg();
}
