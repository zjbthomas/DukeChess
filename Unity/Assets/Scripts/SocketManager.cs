using Socket.Quobject.SocketIoClientDotNet.Client;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using SimpleJSON;

public class SocketManager : MonoBehaviour
{

    public static SocketManager socketManager;

    private QSocket socket;

    void Start()
    {
        Debug.Log("start");
        this.socket = IO.Socket("http://localhost:4115");

        socket.On("game", data => {
            var json = JSON.Parse(data.ToString());
            Debug.Log("message : " + json["message"]);
        });
    }

    void Awake()
    {
        if (socketManager == null)
        {
            socketManager = this;
        }
    }

    private void OnDestroy()
    {
        socket.Disconnect();
    }
}
