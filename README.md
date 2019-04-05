# DukeChess Demo

This is a demo of my favourite boardgame [The Duke](https://boardgamegeek.com/boardgame/36235/duke).

It is originally based on Java 7 with Tomcat 7 websocket (see folder ["Java (deprecated)"](./Java (deprecated))). However, Java is not convinient to re-deploy, and its server is too costly, I convert the project to one based on [Node.js](https://nodejs.org/en/) and [socket.io](https://socket.io/).

You can play it [here](http://www.dexaint.com/dukechess/).

## How to play?

### Game rules

You can get the full rules from [here](https://www.catalystgamelabs.com/download/The%20Duke%20Rulebook%20Hi-Res_FINAL.pdf). For your convenience, a movement reference is provided [here](https://www.catalystgamelabs.com/download/Movement%20Reference%20Card_Final.pdf").

### Run it locally

- Clone the project.
- Make sure you have [`npm`](https://www.npmjs.com/) and `node` ([Node.js](https://nodejs.org/en/)) installed.
- Go to the root directory of the project, and run `npm install` in command point to install all dependencies.
- (Optional) Modify ["/index.js"](./index.js) and ["/public/index.html"](./public/index.html) for port and path.
- (Optional) This project is originally designed on **Windows**. For **Linux**, please modify paths to the following files:
  - Path to ["Chess.xml"](./public/resources/Chess.xml) in ["/public/js-backend/chess/ChessFactory.js"](./public/js-backend/chess/ChessFactory.js);
  - Path to ["Player.properties"](./public/resources/Player.properties) in ["/public/js-backend/flow/Player.js"](./public/js-backend/flow/Player.js)
- Run `node index.js` at the root directory.
- Visit `http://host:port/path` (the default is ["http://localhost:80"](http://localhost)) on two or more pages and enjoy!