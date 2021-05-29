var _createClass=function(){function e(e,t){for(var r=0;r<t.length;r++){var n=t[r];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(e,n.key,n)}}return function(t,r,n){return r&&e(t.prototype,r),n&&e(t,n),t}}();function _classCallCheck(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function _possibleConstructorReturn(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function _inherits(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}var View=function(e){function t(e){var r=e.maxRow,n=e.maxCol;_classCallCheck(this,t);var o=_possibleConstructorReturn(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));return o.createTable=function(){for(var e=[],t=o.props.maxRow-1;t>=0;t--){for(var r=[],n=0;n<o.props.maxCol;n++){var a=t*o.props.maxCol+n;r.push(React.createElement("td",{key:"td"+a},o.renderTile(a)))}e.push(React.createElement("tr",{key:"tr"+t},r))}return e},o.socket=io("/chess"),o.X=null,o.Y=null,o.socket.on("game",(function(e){if(o.setState({connection:e.connection,msg:e.message}),"true"==e.connection)switch(e.type){case"chess":var t=Array(r*n).fill("url(image/empty.png)"),a=!0,i=!1,s=void 0;try{for(var l,c=Object.keys(e)[Symbol.iterator]();!(a=(l=c.next()).done);a=!0){(w=l.value).indexOf("grid")>=0&&(id=parseInt(w.substring("grid_".length)),t[id]=e[w])}}catch(e){i=!0,s=e}finally{try{!a&&c.return&&c.return()}finally{if(i)throw s}}o.setState({chess:t});break;case"color":var u=Array(r*n).fill("grid"),h=!0,p=!1,m=void 0;try{for(var f,y=Object.keys(e)[Symbol.iterator]();!(h=(f=y.next()).done);h=!0){(w=f.value).indexOf("grid")>=0&&(id=parseInt(w.substring("grid_".length)),u[id]="grid "+e[w])}}catch(e){p=!0,m=e}finally{try{!h&&y.return&&y.return()}finally{if(p)throw m}}o.setState({color:u});break;case"menu":var d=[],g=!0,v=!1,b=void 0;try{for(var k,_=Object.keys(e.menus)[Symbol.iterator]();!(g=(k=_.next()).done);g=!0){var w=k.value;d.push(o.renderMenuButton(w,e.menus[w]))}}catch(e){v=!0,b=e}finally{try{!g&&_.return&&_.return()}finally{if(v)throw b}}0!=d.length&&o.setState({menu:d,showMenu:!0,X:o.X,Y:o.Y})}else o.reset(r,n)})),o.state={connection:!1,msg:"",chess:Array(r*n).fill("url(image/empty.png)"),color:Array(r*n).fill("grid"),hover:Array(r*n).fill(""),menu:null,showMenu:!1,X:null,Y:null},o}return _inherits(t,React.Component),_createClass(t,[{key:"reset",value:function(e,t){this.setState({chess:Array(e*t).fill("url(image/empty.png)"),color:Array(e*t).fill("grid"),menu:null,showMenu:!1,X:null,Y:null})}},{key:"onGridClick",value:function(e,t){this.X=t.pageX-window.scrollX,this.Y=t.pageY-window.scrollY,this.socket.emit("game",{type:"grid_click",grid:"grid_"+e})}},{key:"onGridMouseEnter",value:function(e){var t=Array(this.props.maxRow*this.props.maxCol).fill("");t[e]="hovering",this.setState({hover:t}),"true"==this.state.connection&&this.socket.emit("game",{type:"grid_hover",grid:"grid_"+e})}},{key:"onGridMouseLeave",value:function(e){this.setState({hover:Array(this.props.maxRow*this.props.maxCol).fill("")}),this.socket.emit("game",{type:"hover_restore",grid:"grid_"+e})}},{key:"onMenuButtonClick",value:function(e){this.setState({showMenu:!1}),this.socket.emit("game",{type:"menu_click",value:e})}},{key:"renderMenuButton",value:function(e,t){var r=this;return React.createElement("div",{key:e},React.createElement("input",{className:"ibutton",type:"button",value:t,onClick:function(){return r.onMenuButtonClick(t)}}))}},{key:"renderTile",value:function(e){var t=this;return React.createElement(Tile,{id:e,background:(Math.floor(e/this.props.maxRow)%2+e%2)%2==0?"url(image/black.png)":"url(image/white.png)",chess:this.state.chess[e],color:this.state.color[e],hover:this.state.hover[e],onClick:function(r){return t.onGridClick(e,r)},onMouseEnter:function(){t.onGridMouseEnter(e)},onMouseLeave:function(){t.onGridMouseLeave(e)}})}},{key:"renderGame",value:function(){return React.createElement("table",{key:"game",id:"game"},React.createElement("tbody",null,React.createElement("tr",null,React.createElement("td",{id:"board-container"},React.createElement("table",{id:"board"},React.createElement("tbody",null,this.createTable()))))))}},{key:"render",value:function(){var e=[];return e.push(this.renderGame()),e.push(React.createElement(MessageBar,{key:"msgbar",msg:this.state.msg})),this.state.showMenu&&e.push(React.createElement(Menu,{key:"menu",menu:this.state.menu,pageX:this.state.X,pageY:this.state.Y})),e}}]),t}();function MessageBar(e){return React.createElement("div",{id:"msgbar"},e.msg)}function Menu(e){return React.createElement("div",{id:"menu",style:{left:e.pageX,top:e.pageY}},e.menu)}var Tile=function(e){function t(){return _classCallCheck(this,t),_possibleConstructorReturn(this,(t.__proto__||Object.getPrototypeOf(t)).apply(this,arguments))}return _inherits(t,React.Component),_createClass(t,[{key:"render",value:function(){var e=this;return React.createElement("input",{type:"image",alt:"",id:"grid_"+this.props.id,className:this.props.color+" "+this.props.hover,style:{backgroundImage:this.props.chess+","+this.props.background},value:"",onClick:function(t){return e.props.onClick(t)},onMouseEnter:function(){return e.props.onMouseEnter()},onMouseLeave:function(){return e.props.onMouseLeave()}})}}]),t}();ReactDOM.render(React.createElement(View,{maxRow:8,maxCol:8}),document.getElementById("view"));