# DukeChess Demo

This is a demo of my favourite boardgame [The Duke](https://boardgamegeek.com/boardgame/36235/duke).

- [Desktop version](./Godot/):
  - Tech stack: [Godot](https://godotengine.org/)

- Web app version 1:
  - [Front-end](./web-app/React/): [React](https://reactjs.org/)
  - [Back-end](./web-app/): [Node.js](https://nodejs.org/en/) with [Socket.IO](https://socket.io/) and [Redis](https://redis.io/)

- Web app version 2 (deprecated):
  - [Front-end](./deprecated/jQuery/): jQuery
  - [Back-end](./deprecated/Java/): Java 7 with Tomcat 7 WebSocket

## How to play?

### Game rules

You can get the full rules from [here](https://www.catalystgamelabs.com/download/The%20Duke%20Rulebook%20Hi-Res_FINAL.pdf). For your convenience, a movement reference is provided [here](https://www.catalystgamelabs.com/download/Movement%20Reference%20Card_Final.pdf").

### Online version

**This game is available [here](https://dexaint.itch.io/dukechess) to play.**

### Docker version

- Pull the [image](https://hub.docker.com/repository/docker/zjbthomas/dukechess-godot-web/general): `docker pull zjbthomas/dukechess-godot-web`
- Run the container: `docker run --rm -p 80:80 zjbthomas/dukechess-godot-web`
- Visit [`http://127.0.0.1:80/`](http://127.0.0.1:80/)
> ⚠️ Microsoft Edge users: Due to security policies, `localhost` may not work correctly. Please use [`http://127.0.0.1:80/`](http://127.0.0.1:80/) instead.

## How to deploy web app version 1?

### Run it locally

- Clone the project.
- Make sure you have [`npm`](https://www.npmjs.com/) and `node` ([Node.js](https://nodejs.org/en/)) installed.
- Go to the root directory of the project, and run `npm install` in command prompt to install all dependencies.
- (Optional) Modify [index.js"](./web-app/index.js) and ["dukechess/index.html"](./web-app/dukechess/index.html) for port and path.
- (Optional) This project is originally designed on **Windows**. For **Linux**, please modify paths to the following files:
  - Path to ["Chess.xml"](./web-app/dukechess/resources/Chess.xml) in ["dukechess/js-backend/chess/ChessFactory.js"](./web-app/dukechess/js-backend/chess/ChessFactory.js);
  - Path to ["Player.properties"](./web-app/dukechess/resources/Player.properties) in ["dukechess/js-backend/flow/Player.js"](./web-app/dukechess/js-backend/flow/Player.js)
- Run `node index.js` at the root directory.
- Visit `http://host:port/path` (the default is [`http://localhost:80/`](http://localhost:80/)) on two or more pages and enjoy!

### Build it yourself

- You need ["0_babel.bat"](./web-app/React/0_babel.bat) to preprocess JSX.
- You need ["1_terser.bat"](./web-app/React/1_terser.bat) to minify JavaScript for Production.
- More details can be found [here](https://reactjs.org/docs/add-react-to-a-website.html).

# Chess Demo

This code is also adapted for  [here](./web-app/chess/). Chess is available [here](http://games.junbinzhang.com/chess/) to play.
