var webSocket;
var clickEvent;

// Local
var host = "ws://localhost:8080/com.dexaint.dukechess/controller";
// Server
//var host = "wss://tomcat7-dexaint.rhcloud.com:8443/controller";

$(document).ready(function(){
	window.WebSocket = window.WebSocket || window.MozWebSocket;  
    if (!window.WebSocket) { 
        alert("Sorry, but your current browser does not support the game.");  
        return;  
    }  

    webSocket = new WebSocket(host);
    
    webSocket.onmessage = function(event) {
    	json = jQuery.parseJSON(event.data);
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
    }
    
    $(".grid").click(function(event){
    	clickEvent = event;
		webSocket.send('{"type":"grid_click","grid":'+event.target.id+'}');
	});
	
	$(".grid").hover(function(){
		$(event.target).addClass("hovering");
		webSocket.send('{"type":"grid_hover","grid":'+event.target.id+'}');
		
		var img = $(event.target).css("background-image");
		if (img.indexOf("BG") < 0) {
			if (img.indexOf("f") >= 0) {
				img = img.replace("f","b");
			} else {
				img = img.replace("b","f");
			}
			img = img.replace("1","0");
			
			$(".back").css("background-image",img);
			
			$(".back").show();
		}
	},
	function(){
		$(event.target).removeClass("hovering");
		webSocket.send('{"type":"hover_restore","grid":'+event.target.id+'}');
		
		$(".back").hide();
	});
	
	$(".menu").delegate(".ibutton","click",function() {
		$(".menu").hide();
		webSocket.send('{"type":"menu_click","value":'+event.target.value+'}');
	});
});