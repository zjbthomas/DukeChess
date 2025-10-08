var socket;
var clickEvent;
var connection = false;

$(document).ready(function(){
	socket = io();
    
    socket.on("game", function(json) {

		connection = json.connection;

    	if (json.connection == "false") {
    		$("#msgbar")[0].innerHTML = json.message;
    	}
    	else {
    		$("#msgbar")[0].innerHTML = json.message;
    		switch (json.type){
    		case "chess":
    			$(".grid").css("background-image","");
    			$.each(json,function(key,value){
    				if (key.indexOf("grid")>=0) {
    					$(document.getElementById(key)).css("background-image",value);
    				}
				});
    			break;
    		case "color":
    			$(".grid").removeClass("red");
    			$(".grid").removeClass("yellow");
    			$(".grid").removeClass("blue");
    			$(".grid").removeClass("green");
    			$.each(json,function(key,value){
    				if (key.indexOf("grid")>=0) {
    					$(document.getElementById(key)).addClass(value);
    				}
				});
    			break;
    		case "menu":
    			$(".menu").empty();
				$.each(json.menus,function(i,value){
					$(".menu").css("left",clickEvent.pageX);
					$(".menu").css("top",clickEvent.pageY);
					$(".menu").append("<div><input class=\"ibutton\" type=\"button\" value=\""+value+"\"/></div>");
					$(".menu").show();
				});
    			break;
    		}
    	}
    });
    
    $(".grid").click(function(event){
    	clickEvent = event;
		socket.emit("game", {
			type: "grid_click",
			grid: event.target.id
		});
	});
	
	$(".grid").hover(function(){
		$(event.target).addClass("hovering");

		if (connection == "true") {
			socket.emit("game", {
				type: "grid_hover",
				grid: event.target.id
			});
			
			var img = $(event.target).css("background-image");
			if (img.indexOf("BG") < 0) {
				if (img.indexOf("f") >= 0) {
					img = img.replace("f","b");
				} else {
					img = img.replace("b","f");
				}
				
				$(".back").css("background-image",img);
			}
		}
	},
	function(){
		$(event.target).removeClass("hovering");
		socket.emit("game", {
			type: "hover_restore",
			grid: event.target.id
		});

		$(".back").css("background-image","");
	});
	
	$(".menu").delegate(".ibutton","click",function() {
		$(".menu").hide();
		socket.emit("game", {
			type: "menu_click",
			value: event.target.value
		});
	});
});