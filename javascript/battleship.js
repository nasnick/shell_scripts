var location1 = Math.floor(Math.random() * ((2-0)+1) + 0);
var location2 = Math.floor(Math.random() * ((4-3)+1) + 3);
var location3 = Math.floor(Math.random() * ((6-5)+1) + 5);
var guess;
var hits = 0;
var guesses = 0;
var isSunk = false;
var hitShips = [];

while (isSunk == false) {
	console.log(location1);
	console.log(location2);
	console.log(location3);
	guess = prompt("Ready, aim, fire! (enter num between 0-6): ");
	if (guess < 0 || guess > 6) {
		alert("enter valid number");
	} else {
		guesses = guesses + 1;

		if (guess == location1 || guess == location2 || guess == location3) {
			alert("HIT!");
			hitShips.push(guess);
			var sorted_hitShips = hitShips.sort();
			hits = hits + 1;
			for (var i = 0; i < hitShips.length - 1; i++)
			{
				if (hitShips[i] == guess && sorted_hitShips[i + 1] == guess) {
					alert("you have already hit that ship. Guess again.")
					guesses -= 1;
					hits -= 1;
					guess = '';
					break
				}
			}
			if (hits == 3) {
				isSunk = true; 
				alert("You sunk my battleshit");
				break
			}
		  } else { 
			  alert("MISS!");
		  }
	        if (guesses == 4) {
	        	alert("you've run out of guesses");
				break
   	}
	}
};
var stats = "you had " + guesses + " guesses, " + hits + " hits, with " +  (hits/guesses * 100) + "% accuracy";
alert(stats);
