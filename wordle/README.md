Credit original project was rooted from:<br>
https://www.freecodecamp.org/news/build-a-wordle-clone-in-javascript/<br>
https://wordle-clone-drab.vercel.app/<br>
https://github.com/Morgenstern2573/wordle_clone<br><br>


I took the code from <a href="https://github.com/Morgenstern2573">Morgenstern2573</a> Github and added some of our 'required' logic to it for the purposes of our game.

The requirement was to have a CTF - Capture the Flag game where:  using a finite list of words, the player would be required to 'win' or guess the work a certain number of times (e.g. 5) and then a flag would be reveiled on the page.  Its not terribly different from the original intent of wordle, but it does have some spin on the game.  Two lists of words (full guessable & smaller / subset list to pick from), a goal number of correct guesses, and then a secret message to be displayed(flag).


<ul>
<li>index.html - the page</li>
<li>jmodule.js - the logic of the page</li>
<li>style.css - make things look pretty</li>
<li>tf.js - list of flags to be displayed once the correct number of words have been guessed</li>
<li>wl.js - subset of words to pick from.  This limits which wordle words will be correctly 'guessable'</li>
<li>words-org.js - full list of guessable words</li>
</ul>

Props to <a href="https://github.com/Morgenstern2573">Morgenstern2573</a> for getting this started with a great base!