window.addEventListener("keydown", function(e) {
    //arrow keys
    if([13, 37, 38, 39, 40].indexOf(e.keyCode) > -1) {
    	e.preventDefault();
    }
}, false);

function create(){
	var room = document.getElementById("room").value;
	var hostname = document.getElementById("hostname").value;
	var guestname = document.getElementById("guestname").value;
	$.ajax({  
		type: "POST",  
		url: "/create",  
		data: {'room' : room, 'hostname' : hostname, 'guestname' : guestname },  
		success: function(data) {  
			console.log(data)
			console.log('Room created.'); 
		}  
	}); 

}

function loadgame(){
	$.ajax({  
		type: "POST",  
		url: "/load",  
		data: {'room' : document.getElementById("room-name").innerHTML},  
		success: function(data) {  
			console.log(data)
			$('#tile-container').html(drawer(data.board));
			$('#score').html(data.score);
			$('#turn').html(data[data.turn]);
			console.log('game loaded.'); 
		}  
	}); 

}

function join(){
	var room = document.getElementById("room1").value;
	var name = document.getElementById("name1").value;
	$.ajax({  
		type: "POST",  
		url: "/join",  
		data: {'room' : room, 'name' : name},  
		success: function(data) {  
			console.log('joining room.');
			window.location = "/game"; 
		}  
	}); 
}

function drawer(data){
	var drawn_board = '';
	for (var i = 0; i < 4; i++) {
		for (var j = 0; j < 4; j++){
			if (data[i][j] != 0){
				drawn_board = drawn_board + "<div class=\"tile tile-" + data[i][j] + " tile-position-" + (j+1) + "-" + (i+1) + " tile-new\"><div class=\"tile-inner\">" + data[i][j] + "</div></div>";
			}
		}
	}
	return drawn_board;
}


function sendchat(){

}

$(function(){
	console.log("im here");
	var room = "/"+document.getElementById("room-name").innerHTML+"";
	var chat = "/"+document.getElementById("room-name").innerHTML+"/chat";
	var client = new Faye.Client('http://localhost:9292/faye');

	client.subscribe(room, function(data) {
					//alert(data)
					//console.log(data)
					$('#tile-container').html(drawer(data.board));
					$('#score').html(data.score);
					$('#turn').html(data[data.turn]);
				});

	client.subscribe(chat, function(data) {
		$('#chat-area').val( $('#chat-area').val() + "\n" +data.message+"");
	});
});

function move(move){
	$.ajax({  
		type: "POST",  
		url: "/move",  
		data: {'move' : move, 'room' : document.getElementById("room-name").innerHTML, 'user' : document.getElementById("user-name").innerHTML},  
		success: function(data) {  
			console.log('moved...'); 
		}  
	}); 
}

$(document).ready(function() {
	// action on key down
$(document).keydown(function(e) {
	if(e.which == 13) {
		$.ajax({  
			type: "POST",  
			url: "/sendchat",  
			data: {'room' : document.getElementById("room-name").innerHTML, 'user' : document.getElementById("user-name").innerHTML, 'message' : document.getElementById("chat-input").value},  
			success: function(data) {  
				$('#chat-input').val("");
				console.log('message sent...'); 
			}  
		});
	}

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




