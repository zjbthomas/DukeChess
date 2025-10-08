using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;

public class ChessListener : MonoBehaviour, IPointerDownHandler, IPointerEnterHandler, IPointerExitHandler
{
    private bool isHovering;
    private bool isWaiting;


    public void Awake()
    {
        isHovering = false;
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        // Do nothing if an animation or a menu is ongoing
        if (GameManager.GetInAnimation() || GameManager.GetIsWaitingMenu())
        {
            return;
        }
        ChessController chess = this.GetComponent<ChessController>();
        chess.GetGameModel().TryChess(chess.GetIndex());
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        // No matter how, update the hovering flag
        isHovering = true;
        // Do nothing if an animation or a menu is ongoing
        if (GameManager.GetInAnimation() || GameManager.GetIsWaitingMenu())
        {
            return;
        }
        // Otherwise, render masks
        ChessController chess = this.GetComponent<ChessController>();
        chess.GetGameModel().HandleHover(isHovering, chess.GetIndex());
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        isHovering = false;
        // Do nothing if a menu is ongoing
        if (GameManager.GetIsWaitingMenu())
        {
            return;
        }
        // Render masks
        ChessController chess = this.GetComponent<ChessController>();
        chess.GetGameModel().HandleHover(isHovering, chess.GetIndex());
    }

}
