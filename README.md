# DukeChess Demo

This is a demo of my favourite boardgame [The Duke](https://boardgamegeek.com/boardgame/36235/duke).

It is originally based on Java 7 with Tomcat 7 websocket (see folder ["/Java-deprecated/"](./Java-deprecated/)), and jQurey (see folder ["/jQuery-deprecated/"](./jQuery-deprecated/)). The latest version is based on [Node.js](https://nodejs.org/en/), [socket.io](https://socket.io/), and [React](https://reactjs.org/).

## How to play?

### Game rules

You can get the full rules from [here](https://www.catalystgamelabs.com/download/The%20Duke%20Rulebook%20Hi-Res_FINAL.pdf). For your convenience, a movement reference is provided [here](https://www.catalystgamelabs.com/download/Movement%20Reference%20Card_Final.pdf").

### Online version

**This game is available [here](http://games.junbinzhang.com/dukechess/) to play.**

### Run it locally

- Clone the project.
- Make sure you have [`npm`](https://www.npmjs.com/) and `node` ([Node.js](https://nodejs.org/en/)) installed.
- Go to the root directory of the project, and run `npm install` in command prompt to install all dependencies.
- (Optional) Modify ["/index.js"](./index.js) and ["/dukechess/index.html"](./dukechess/index.html) for port and path.
- (Optional) This project is originally designed on **Windows**. For **Linux**, please modify paths to the following files:
  - Path to ["Chess.xml"](./dukechess/resources/Chess.xml) in ["/dukechess/js-backend/chess/ChessFactory.js"](./dukechess/js-backend/chess/ChessFactory.js);
  - Path to ["Player.properties"](./dukechess/resources/Player.properties) in ["/dukechess/js-backend/flow/Player.js"](./dukechess/js-backend/flow/Player.js)
- Run `node index.js` at the root directory.
- Visit `http://host:port/path` (the default is ["http://localhost:80/"](http://localhost/)) on two or more pages and enjoy!

### Build it yourself

- Source code of [React](https://reactjs.org/) is under folder ["/React/src/"](./React/src).
- You need ["/React/0_babel.bat"](./React/0_babel.bat) to preprocess JSX.
- You need ["/React/1_terser.bat"](./React/1_terser.bat) to minify JavaScript for Production.
- More details can be found [here](https://reactjs.org/docs/add-react-to-a-website.html).

# Chess Demo

The code is also adapted for Chess, under the folder ["/chess/"](./chess/)). Chess is available [here](http://games.junbinzhang.com/chess/) to play.
