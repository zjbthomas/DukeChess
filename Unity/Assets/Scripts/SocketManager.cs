using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using BestHTTP.SocketIO;

public class SocketManager : MonoBehaviour
{

    public static SocketManager socketManager;

    private BestHTTP.SocketIO.SocketManager manager;
    private Socket socket;

    private bool isGaming = false;

    void Start()
    {
        this.manager = new BestHTTP.SocketIO.SocketManager(new Uri("http://localhost/socket.io/"));
        this.socket = this.manager.GetSocket("/dukechess");

        socket.On(SocketIOEventTypes.Connect, (s, p, a) =>
        {
            socket.Emit("platform", "unity");
        });

        socket.On("game", (s, p, a) => {
            Dictionary<string, object>  json = (Dictionary<string, object>) a[0];
            GameManager.gameManager.SetMessage(json["message"].ToString());
            if (String.Equals(json["connection"], "true"))
            {
                this.isGaming = true;

                string type = json["type"].ToString();
        
                switch (type)
                {
                    case "init":
                        GameManager.gameManager.StartGame(String.Equals(json["firstplayer"], "true"));
                        break;
                    case "color":
                        GameManager.gameManager.GetGameModel().RenderMask(json);
                        break;
                    case "game":
                        GameManager.gameManager.GetGameModel().PerformOp(json);
                        GameManager.gameManager.GetGameModel().RenderMask(json);

                        if (String.Equals(json["active"], "true"))
                        {
                            switch (json["subtype"].ToString())
                            {
                                case "nomenu":
                                    // Hide menu when a nomenu subtype is sent
                                    GameManager.gameManager.GetGameModel().RenderMenu(null);
                                    break;
                                case "inmenu":
                                    GameManager.gameManager.GetGameModel().RenderMenu(json);
                                    break;

                            }
                        }
                        else {
                            // Hide menu when not active
                            GameManager.gameManager.GetGameModel().RenderMenu(null);
                        }
                        break;
                }

                //if (int.Parse(json["state"].ToString()) == (int)GameModel.GameState.INITIALIZATION)
                //{
                //    GameManager.gameManager.StartGame();
                //}
            }
            else {
                this.isGaming = false;
            }
        });
    }

    public void EmitMessage(string key, Dictionary<string, string> json) {
        if (isGaming) {
            this.socket.Emit(key, json);
        }
    }

    void Awake()
    {
        if (socketManager == null)
        {
            socketManager = this;
        }
    }
}
