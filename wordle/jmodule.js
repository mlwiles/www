//https://www.obfuscator.io/

import { TF } from "./tf.js";
import { WL } from "./wl.js";
import { WO } from "./words-org.js";

const NUMBER_OF_GUESSES = 6;
let totalCorrect = 0;
let goalCorrect = 5;

let guessesRemaining = NUMBER_OF_GUESSES;
let currentGuess = [];
let nextLetter = 0;
let rightGuessString = WL[Math.floor(Math.random() * WL.length)]

console.log(rightGuessString)

function nextWord() {
    document.getElementById("next-board").style.visibility = "hidden";
    reInitBoard();
}

function initBoard() {
    guessesRemaining = NUMBER_OF_GUESSES;
    currentGuess = [];
    nextLetter = 0;
    rightGuessString = WL[Math.floor(Math.random() * WL.length)]
    let board = document.getElementById("game-board");

    for (let i = 0; i < NUMBER_OF_GUESSES; i++) {
        let row = document.createElement("div")
        row.className = "letter-row"
        
        for (let j = 0; j < 5; j++) {
            let box = document.createElement("div")
            box.className = "letter-box"
            row.appendChild(box)
        }
        board.appendChild(row)
    }
}

function eraseBoard() {
    let board = document.getElementById("game-board");
    let boardrows = board.getElementsByClassName("letter-row");

    let boardboxes =  board.getElementsByClassName("letter-box");
    for (let i = boardboxes.length; i > 0; i--) {
        try {
            boardrows[0].remove(boardboxes[i]);
        } catch (error) {
        }  
    }

    boardboxes =  board.getElementsByClassName("letter-box box-filled");
    for (let i = boardboxes.length; i > 0; i--) {
        try {
            boardrows[0].remove(boardboxes[i]);
        } catch (error) {
        }  
    }
}

function reInitBoard() {
    eraseBoard();
    initKeyboard('white');
    initBoard();
}

function initKeyboard(color) {
    let letter =['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];

    for (let i = 0; i < letter.length; i++) {
        shadeKeyBoard2(letter[i], color);
    }
}

function shadeKeyBoard2(letter, color) {
    for (const elem of document.getElementsByClassName("keyboard-button")) {
        if (elem.textContent === letter) {
           elem.style.backgroundColor = color
        }
    }
}

function shadeKeyBoard(letter, color) {
    for (const elem of document.getElementsByClassName("keyboard-button")) {
        if (elem.textContent === letter) {
            let oldColor = elem.style.backgroundColor
            if (oldColor === 'green') {
                return
            } 

            if (oldColor === 'yellow' && color !== 'green') {
                return
            }

            elem.style.backgroundColor = color
            break
        }
    }
}

function deleteLetter () {
    let row = document.getElementsByClassName("letter-row")[6 - guessesRemaining]
    let box = row.children[nextLetter - 1]
    box.textContent = ""
    box.classList.remove("filled-box")
    currentGuess.pop()
    nextLetter -= 1
}

function checkGuess () {
    let row = document.getElementsByClassName("letter-row")[6 - guessesRemaining]
    let guessString = ''
    let rightGuess = Array.from(rightGuessString)

    for (const val of currentGuess) {
        guessString += val
    }

    if (guessString.length != 5) {
        toastr.error("Not enough letters!")
        return
    }

    if (!WO.includes(guessString)) {
        toastr.error("Word not in list!")
        return
    }

    
    for (let i = 0; i < 5; i++) {
        let letterColor = ''
        let box = row.children[i]
        let letter = currentGuess[i]
        
        let letterPosition = rightGuess.indexOf(currentGuess[i])
        // is letter in the correct guess
        if (letterPosition === -1) {
            letterColor = 'grey'
        } else {
            // now, letter is definitely in word
            // if letter index and right guess index are the same
            // letter is in the right position 
            if (currentGuess[i] === rightGuess[i]) {
                // shade green 
                letterColor = 'green'
            } else {
                // shade box yellow
                letterColor = 'yellow'
            }

            rightGuess[letterPosition] = "#"
        }

        let delay = 250 * i
        setTimeout(()=> {
            //flip box
            animateCSS(box, 'flipInX')
            //shade box
            box.style.backgroundColor = letterColor
            shadeKeyBoard(letter, letterColor)
        }, delay)
    }

    if (guessString === rightGuessString) {
        guessesRemaining = 0
        totalCorrect++;
        if ( totalCorrect === goalCorrect ) {
            eraseBoard();
            document.getElementById("next-board").style.visibility = "hidden";
            toastr.success("Congratulations - You Captured The Flag!")
            initKeyboard('green');
            //sleep(2000);
            document.getElementById("message").innerHTML = `F L A G: <br>${TF[Math.floor(Math.random() * TF.length)]}`;
        } else {
            toastr.success("You guessed right!")
            toastr.info("Click 'next word' to clear the board and get another word")
            document.getElementById("message").innerHTML = `Guessed: ${totalCorrect} of ${goalCorrect}`;
            document.getElementById("next-board").style.visibility = "";
        }
        return
    } else {
        guessesRemaining -= 1;
        currentGuess = [];
        nextLetter = 0;

        if (guessesRemaining === 0) {
            toastr.error("You've run out of guesses!")
            toastr.info(`The right word was: "${rightGuessString}"`)
            toastr.info("Click 'next word' to clear the board and get another word")
            document.getElementById("message").innerHTML = `Guessed: ${totalCorrect} of ${goalCorrect}`;
            document.getElementById("next-board").style.visibility = "";
        }
    }
}

function insertLetter (pressedKey) {
    if (nextLetter === 5) {
        return
    }
    pressedKey = pressedKey.toLowerCase()

    let row = document.getElementsByClassName("letter-row")[6 - guessesRemaining]
    let box = row.children[nextLetter]
    animateCSS(box, "pulse")
    box.textContent = pressedKey
    box.classList.add("filled-box")
    currentGuess.push(pressedKey)
    nextLetter += 1
}

function sleep(ms) {
    //return new Promise(resolve => setTimeout(resolve, ms));
    var now = new Date().getTime();
    while(new Date().getTime() < now + ms){ 
        /* Do nothing */ 
    }
}

const animateCSS = (element, animation, prefix = 'animate__') =>
  // We create a Promise and return it
  new Promise((resolve, reject) => {
    const animationName = `${prefix}${animation}`;
    // const node = document.querySelector(element);
    const node = element
    node.style.setProperty('--animate-duration', '0.1s');
    
    node.classList.add(`${prefix}animated`, animationName);

    // When the animation ends, we clean the classes and resolve the Promise
    function handleAnimationEnd(event) {
      event.stopPropagation();
      node.classList.remove(`${prefix}animated`, animationName);
      resolve('Animation ended');
    }

    node.addEventListener('animationend', handleAnimationEnd, {once: true});
});

document.addEventListener("keyup", (e) => {

    if (guessesRemaining === 0) {
        return
    }

    let pressedKey = String(e.key)
    if (pressedKey === "Backspace" && nextLetter !== 0) {
        deleteLetter()
        return
    }

    if (pressedKey === "Enter") {
        checkGuess()
        return
    }

    let found = pressedKey.match(/[a-z]/gi)
    if (!found || found.length > 1) {
        return
    } else {
        insertLetter(pressedKey)
    }
})

document.getElementById("keyboard-cont").addEventListener("click", (e) => {
    const target = e.target
    
    if (!target.classList.contains("keyboard-button")) {
        return
    }
    let key = target.textContent

    if (key === "Del") {
        key = "Backspace"
    } 

    document.dispatchEvent(new KeyboardEvent("keyup", {'key': key}))
})

document.getElementById("next-word").addEventListener("click", (e) => {
    nextWord();
})

initBoard();
