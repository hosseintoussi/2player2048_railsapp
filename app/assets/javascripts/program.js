
window.addEventListener("keydown", function(e) {
    //arrow keys
    if([13, 37, 38, 39, 40].indexOf(e.keyCode) > -1) {
    	e.preventDefault();
    }
}, false);

function loadgame(){
	$.ajax({
		type: "POST",
		url: "/load",
		data: {"room" : {"room" : document.getElementById("room-name").innerHTML}},
		success: function(data) {
			$('#score').html(data.score);
			$('#turn').html(data.turn);
			$('#tile-container').html(drawer(data.board));
			console.log('game loaded.');
		}
	});

}

function drawer(data){
	var drawn_board = '';
	for (var i = 0; i < 4; i++) {
		for (var j = 0; j < 4; j++){
			if (data[i][j] != 0){
				drawn_board = drawn_board + "<div class=\"tile tile-"
				+ data[i][j] + " tile-position-" + (j+1) + "-" + (i+1)
				+ " tile-new\"><div class=\"tile-inner\">" + data[i][j]
				+ "</div></div>";
			}
		}
	}
	return drawn_board;
}

$(function(){
	var room = "/"+document.getElementById("room-name").innerHTML+"";
	var chat = "/"+document.getElementById("room-name").innerHTML+"/chat";
	var client = new Faye.Client('http://localhost:9292/faye');

	client.subscribe(room, function(data) {
					$('#tile-container').html(drawer(data.board));
					$('#score').html(data.score);
					$('#turn').html(data.turn);
				});

	client.subscribe(chat, function(data) {
		$('#chat-area').val( $('#chat-area').val() + "\n" +data.message+"");
	});
});


function move(move){
	$.ajax({
		type: "POST",
		url: "/move",
		data: {'room': {'move' : move, 'room' : document.getElementById("room-name").innerHTML, 'user' : document.getElementById("user-name").innerHTML}},
		success: function(data) {
			console.log('moved...');

		}
	});
}

$(function() {
		// action on key down
	$(document).keydown(function(e) {

		if(e.which == 38) {
			move('w');
		}

		if(e.which == 39) {
			move('d');
		}

		if(e.which == 40) {
			move('s');
		}

		if(e.which == 37) {
			move('a');
		}
	});

});




