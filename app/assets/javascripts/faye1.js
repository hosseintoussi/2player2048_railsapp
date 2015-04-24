$(function(){
	console.log("im here")
	var client = new Faye.Client('http://localhost:9292/faye');
	client.subscribe("/messages/new", function(data) {
					//alert(data)
					//console.log(data)
					$('#tile-container').html(data.board);
					$('#score-container').html(data.score);
	});
});
