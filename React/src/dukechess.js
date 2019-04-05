class View extends React.Component {
    constructor({maxRow, maxCol}) {
        super()

        this.socket = io()

        this.socket.on("game", json => {
            this.setState({
                connection: json.connection,
                msg: json.message
            })

            if (json.connection == "true") {
                switch (json.type){
                    case "chess":
                        var chess = Array(maxRow * maxCol).fill("url(../image/BG.png)")

                        for (var key of Object.keys(json)) {
                            if (key.indexOf("grid")>=0) {
                                id = parseInt(key.substring("grid_".length))

                                chess[id] = json[key]
                            }
                        }

                        this.setState({chess: chess})

                        break;
                    case "color":
                        var color = Array(maxRow * maxCol).fill("grid")

                        for (var key of Object.keys(json)) {
                            if (key.indexOf("grid")>=0) {
                                id = parseInt(key.substring("grid_".length))

                                color[id] = "grid " + json[key]
                            }
                        }

                        this.setState({color: color})

                        break;
                    case "menu":
                        var menus = []

                        for (var key of Object.keys(json.menus)) {
                            menus.push(this.renderMenuButton(key, json.menus[key]))
                            this.setState({showMenu: true})
                        }

                        this.setState({menu: menus})
                        break;
                    }
            }
        })

        this.state = {
            connection: false,
            msg: "",
            chess: Array(maxRow * maxCol).fill("url(../image/BG.png)"),
            color: Array(maxRow * maxCol).fill("grid"),
            hover: Array(maxRow * maxCol).fill(""),
            menu: null,
            showMenu: false,
            X: null,
            Y: null,
            backImg: "url(../image/BG.png)"
        }
    }

    onGridClick(i, event) {
        this.setState({
            X: event.pageX - window.scrollX,
            Y: event.pageY - window.scrollY
        })

        this.socket.emit("game", {
			type: "grid_click",
			grid: "grid_" + i
		});
    }

    onGridMouseEnter(i) {
        var hover = Array(this.props.maxRow * this.props.maxCol).fill("")
        hover[i] = "hovering"
        this.setState({hover: hover})

        if (this.state.connection == "true") {
            this.socket.emit("game", {
				type: "grid_hover",
				grid: "grid_" + i
            });
            
            var img = this.state.chess[i]
            if (img.indexOf("BG") < 0) {
				if (img.indexOf("f") >= 0) {
					img = img.replace("f","b");
				} else {
					img = img.replace("b","f");
                }

                this.setState({backImg: img})
            }
        }
    }

    onGridMouseLeave(i) {
        this.setState({hover: Array(this.props.maxRow * this.props.maxCol).fill("")})

        this.socket.emit("game", {
			type: "hover_restore",
			grid: "grid_" + i
        });
        
        this.setState({backImg: "url(../image/BG.png)"})
    }

    onMenuButtonClick(value) {
        this.setState({showMenu: false})

        this.socket.emit("game", {
			type: "menu_click",
			value: value
		});
    }

    renderMenuButton(key, value) {
        return(
            <div key={key}>
                <input
                    className="ibutton"
                    type="button"
                    value={value}
                    onClick={() => this.onMenuButtonClick(value)}
                />
            </div>
        )
    }

    renderTile(i) {
        return (
            <Tile
                id={i}
                chess={this.state.chess[i]}
                color={this.state.color[i]}
                hover={this.state.hover[i]}
                onClick={(event) => this.onGridClick(i, event)}
                onMouseEnter={() => {this.onGridMouseEnter(i)}}
                onMouseLeave={() => {this.onGridMouseLeave(i)}}
            />
        )
    }

    createTable = () => {
        let table = []

        for (var i = this.props.maxRow - 1; i >= 0; i--) {
            let row = []
			for (var j = 0; j < this.props.maxCol; j++) {
                var index = i * this.props.maxCol + j
                row.push(<td key={"td" + index}>{this.renderTile(index)}</td>)
			}
            table.push(<tr key={"tr" + i}>{row}</tr>)
        }

        return table
    }

    renderGame() {
        return (
            <table key="game" id="game">
                <tbody>
                    <tr>
                        <td className="left" id="board-container">
                            <table id="board">
                                <tbody>
                                    {this.createTable()}
                                </tbody>
                            </table>
                        </td>
                        <td className="right">
                            <div className="chess-info">
                                <h4>Back</h4>
                                <Back img={this.state.backImg} />
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        )
    }

    render() {
        let components = []

        components.push(this.renderGame())
        components.push(<MessageBar key="msgbar" msg={this.state.msg}/>)

        if (this.state.showMenu) {
            components.push(<Menu key="menu" menu={this.state.menu} pageX={this.state.X} pageY={this.state.Y} />)
        }
        return components
    }
}

function MessageBar(props) {
    return (
        <div id="msgbar">{props.msg}</div>
    )
}

function Menu(props) {
    return (
        <div
            id="menu"
            style={{
                left : props.pageX,
                top : props.pageY
        }}>
            {props.menu}
        </div>
    )
}

function Back(props) {
    return (
        <div
            className="chess-holder"
            style={{backgroundImage : props.img}}
        />
    )
}

class Tile extends React.Component {
    render() {
        return (
            <input
                type="image"
                alt=""
                id={"grid_" + this.props.id}
                className={this.props.color + " " + this.props.hover}
                style={{backgroundImage : this.props.chess}}
                value=""
                onClick={(event) => this.props.onClick(event)}
                onMouseEnter={() => this.props.onMouseEnter()}
                onMouseLeave={() => this.props.onMouseLeave()}
                />
        )
    }
}

ReactDOM.render(
    <View maxRow={6} maxCol={6} />,
    document.getElementById("view")
);