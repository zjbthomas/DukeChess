var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var View = function (_React$Component) {
    _inherits(View, _React$Component);

    function View(_ref) {
        var maxRow = _ref.maxRow,
            maxCol = _ref.maxCol;

        _classCallCheck(this, View);

        var _this = _possibleConstructorReturn(this, (View.__proto__ || Object.getPrototypeOf(View)).call(this));

        _this.createTable = function () {
            var table = [];

            for (var i = _this.props.maxRow - 1; i >= 0; i--) {
                var row = [];
                for (var j = 0; j < _this.props.maxCol; j++) {
                    var index = i * _this.props.maxCol + j;
                    row.push(React.createElement(
                        "td",
                        { key: "td" + index },
                        _this.renderTile(index)
                    ));
                }
                table.push(React.createElement(
                    "tr",
                    { key: "tr" + i },
                    row
                ));
            }

            return table;
        };

        _this.socket = io();

        _this.X = null;
        _this.Y = null;

        _this.socket.on("game", function (json) {
            _this.setState({
                connection: json.connection,
                msg: json.message
            });

            if (json.connection == "true") {
                switch (json.type) {
                    case "chess":
                        var chess = Array(maxRow * maxCol).fill("url(image/BG.png)");

                        var _iteratorNormalCompletion = true;
                        var _didIteratorError = false;
                        var _iteratorError = undefined;

                        try {
                            for (var _iterator = Object.keys(json)[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
                                var key = _step.value;

                                if (key.indexOf("grid") >= 0) {
                                    id = parseInt(key.substring("grid_".length));

                                    chess[id] = json[key];
                                }
                            }
                        } catch (err) {
                            _didIteratorError = true;
                            _iteratorError = err;
                        } finally {
                            try {
                                if (!_iteratorNormalCompletion && _iterator.return) {
                                    _iterator.return();
                                }
                            } finally {
                                if (_didIteratorError) {
                                    throw _iteratorError;
                                }
                            }
                        }

                        _this.setState({ chess: chess });

                        break;
                    case "color":
                        var color = Array(maxRow * maxCol).fill("grid");

                        var _iteratorNormalCompletion2 = true;
                        var _didIteratorError2 = false;
                        var _iteratorError2 = undefined;

                        try {
                            for (var _iterator2 = Object.keys(json)[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
                                var key = _step2.value;

                                if (key.indexOf("grid") >= 0) {
                                    id = parseInt(key.substring("grid_".length));

                                    color[id] = "grid " + json[key];
                                }
                            }
                        } catch (err) {
                            _didIteratorError2 = true;
                            _iteratorError2 = err;
                        } finally {
                            try {
                                if (!_iteratorNormalCompletion2 && _iterator2.return) {
                                    _iterator2.return();
                                }
                            } finally {
                                if (_didIteratorError2) {
                                    throw _iteratorError2;
                                }
                            }
                        }

                        _this.setState({ color: color });

                        break;
                    case "menu":
                        var menus = [];

                        var _iteratorNormalCompletion3 = true;
                        var _didIteratorError3 = false;
                        var _iteratorError3 = undefined;

                        try {
                            for (var _iterator3 = Object.keys(json.menus)[Symbol.iterator](), _step3; !(_iteratorNormalCompletion3 = (_step3 = _iterator3.next()).done); _iteratorNormalCompletion3 = true) {
                                var key = _step3.value;

                                menus.push(_this.renderMenuButton(key, json.menus[key]));
                            }
                        } catch (err) {
                            _didIteratorError3 = true;
                            _iteratorError3 = err;
                        } finally {
                            try {
                                if (!_iteratorNormalCompletion3 && _iterator3.return) {
                                    _iterator3.return();
                                }
                            } finally {
                                if (_didIteratorError3) {
                                    throw _iteratorError3;
                                }
                            }
                        }

                        if (menus.length != 0) {
                            _this.setState({
                                menu: menus,
                                showMenu: true,
                                X: _this.X,
                                Y: _this.Y
                            });
                        }
                        break;
                }
            } else {
                _this.reset(maxRow, maxCol);
            }
        });

        _this.state = {
            connection: false,
            msg: "",
            chess: Array(maxRow * maxCol).fill("url(image/BG.png)"),
            color: Array(maxRow * maxCol).fill("grid"),
            hover: Array(maxRow * maxCol).fill(""),
            menu: null,
            showMenu: false,
            X: null,
            Y: null,
            backImg: "url(image/BG.png)"
        };
        return _this;
    }

    _createClass(View, [{
        key: "reset",
        value: function reset(maxRow, maxCol) {
            this.setState({
                chess: Array(maxRow * maxCol).fill("url(image/BG.png)"),
                color: Array(maxRow * maxCol).fill("grid"),
                hover: Array(maxRow * maxCol).fill(""),
                menu: null,
                showMenu: false,
                X: null,
                Y: null,
                backImg: "url(image/BG.png)"
            });
        }
    }, {
        key: "onGridClick",
        value: function onGridClick(i, event) {
            this.X = event.pageX - window.scrollX;
            this.Y = event.pageY - window.scrollY;

            this.socket.emit("game", {
                type: "grid_click",
                grid: "grid_" + i
            });
        }
    }, {
        key: "onGridMouseEnter",
        value: function onGridMouseEnter(i) {
            var hover = Array(this.props.maxRow * this.props.maxCol).fill("");
            hover[i] = "hovering";
            this.setState({ hover: hover });

            if (this.state.connection == "true") {
                this.socket.emit("game", {
                    type: "grid_hover",
                    grid: "grid_" + i
                });

                var img = this.state.chess[i];
                if (img.indexOf("BG") < 0) {
                    if (img.indexOf("f") >= 0) {
                        img = img.replace("f", "b");
                    } else {
                        img = img.replace("b", "f");
                    }

                    this.setState({ backImg: img });
                }
            }
        }
    }, {
        key: "onGridMouseLeave",
        value: function onGridMouseLeave(i) {
            this.setState({ hover: Array(this.props.maxRow * this.props.maxCol).fill("") });

            this.socket.emit("game", {
                type: "hover_restore",
                grid: "grid_" + i
            });

            this.setState({ backImg: "url(image/BG.png)" });
        }
    }, {
        key: "onMenuButtonClick",
        value: function onMenuButtonClick(value) {
            this.setState({ showMenu: false });

            this.socket.emit("game", {
                type: "menu_click",
                value: value
            });
        }
    }, {
        key: "renderMenuButton",
        value: function renderMenuButton(key, value) {
            var _this2 = this;

            return React.createElement(
                "div",
                { key: key },
                React.createElement("input", {
                    className: "ibutton",
                    type: "button",
                    value: value,
                    onClick: function onClick() {
                        return _this2.onMenuButtonClick(value);
                    }
                })
            );
        }
    }, {
        key: "renderTile",
        value: function renderTile(i) {
            var _this3 = this;

            return React.createElement(Tile, {
                id: i,
                chess: this.state.chess[i],
                color: this.state.color[i],
                hover: this.state.hover[i],
                onClick: function onClick(event) {
                    return _this3.onGridClick(i, event);
                },
                onMouseEnter: function onMouseEnter() {
                    _this3.onGridMouseEnter(i);
                },
                onMouseLeave: function onMouseLeave() {
                    _this3.onGridMouseLeave(i);
                }
            });
        }
    }, {
        key: "renderGame",
        value: function renderGame() {
            return React.createElement(
                "table",
                { key: "game", id: "game" },
                React.createElement(
                    "tbody",
                    null,
                    React.createElement(
                        "tr",
                        null,
                        React.createElement(
                            "td",
                            { className: "left", id: "board-container" },
                            React.createElement(
                                "table",
                                { id: "board" },
                                React.createElement(
                                    "tbody",
                                    null,
                                    this.createTable()
                                )
                            )
                        ),
                        React.createElement(
                            "td",
                            { className: "right" },
                            React.createElement(
                                "div",
                                { className: "chess-info" },
                                React.createElement(
                                    "h4",
                                    null,
                                    "Back"
                                ),
                                React.createElement(Back, { img: this.state.backImg })
                            )
                        )
                    )
                )
            );
        }
    }, {
        key: "render",
        value: function render() {
            var components = [];

            components.push(this.renderGame());
            components.push(React.createElement(MessageBar, { key: "msgbar", msg: this.state.msg }));

            if (this.state.showMenu) {
                components.push(React.createElement(Menu, { key: "menu", menu: this.state.menu, pageX: this.state.X, pageY: this.state.Y }));
            }
            return components;
        }
    }]);

    return View;
}(React.Component);

function MessageBar(props) {
    return React.createElement(
        "div",
        { id: "msgbar" },
        props.msg
    );
}

function Menu(props) {
    return React.createElement(
        "div",
        {
            id: "menu",
            style: {
                left: props.pageX,
                top: props.pageY
            } },
        props.menu
    );
}

function Back(props) {
    return React.createElement("div", {
        className: "chess-holder",
        style: { backgroundImage: props.img }
    });
}

var Tile = function (_React$Component2) {
    _inherits(Tile, _React$Component2);

    function Tile() {
        _classCallCheck(this, Tile);

        return _possibleConstructorReturn(this, (Tile.__proto__ || Object.getPrototypeOf(Tile)).apply(this, arguments));
    }

    _createClass(Tile, [{
        key: "render",
        value: function render() {
            var _this5 = this;

            return React.createElement("input", {
                type: "image",
                alt: "",
                id: "grid_" + this.props.id,
                className: this.props.color + " " + this.props.hover,
                style: { backgroundImage: this.props.chess },
                value: "",
                onClick: function onClick(event) {
                    return _this5.props.onClick(event);
                },
                onMouseEnter: function onMouseEnter() {
                    return _this5.props.onMouseEnter();
                },
                onMouseLeave: function onMouseLeave() {
                    return _this5.props.onMouseLeave();
                }
            });
        }
    }]);

    return Tile;
}(React.Component);

ReactDOM.render(React.createElement(View, { maxRow: 6, maxCol: 6 }), document.getElementById("view"));