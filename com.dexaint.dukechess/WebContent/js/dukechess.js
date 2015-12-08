var webSocket;
var clickEvent;

// Local
var host = "ws://localhost:8080/dukechess/controller";
// Server
// var host = "wss://tomcat7-dexaint.rhcloud.com:8443/controller";

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
    		case "grid_click":
    			$(".menu").empty();
				$.each(json.actions,function(i,value){
					$(".menu").css("left",clickEvent.pageX);
					$(".menu").css("top",clickEvent.pageY);
					$(".menu").append("<div><input class=\"ibutton\" type=\"button\" value=\""+value+"\"/></div>");
					$(".menu").show();
				});
    			break;
    		case "menu_click":
    			$.each(json,function(key,value){
    				if ("connection"!=key & "type"!=key) {
    					$(document.getElementById(key)).css("background-image","url(image/Duke_f_1.png)");
    				}
				});
    			break;
    		case "grid_hover":
    			$.each(json,function(key,value){
    				if ("connection"!=key & "type"!=key) {
    					$(document.getElementById(key)).addClass("effect red");
    				}
				});
    			break;
    		}
    	}
    }
    
    $(".grid").click(function(event){
    	clickEvent = event;
		$(".grid").removeAttr("style");
		$(".grid").removeClass().addClass("grid");
		
		webSocket.send('{"type":"grid_click","grid":'+event.target.id+'}');
		
		
	});
	
	$(".grid").hover(function(){
		webSocket.send('{"type":"grid_hover","grid":'+event.target.id+'}');
	},
	function(){
		$(".grid").removeClass().addClass("grid");
	});
	
	$(".menu").delegate(".ibutton","click",function() {
		webSocket.send('{"type":"menu_click","value":'+event.target.value+'}');
	});
	
	$("body").click(function() {
		$(".menu").hide();
	});
});