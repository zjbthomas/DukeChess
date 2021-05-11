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
        // Do nothing if an animation is ongoing
        if (GameManager.GetInAnimation()) {
            return;
        }
        ChessController chess = this.GetComponent<ChessController>();
        chess.GetGameModel().PerformOp(chess.GetIndex());

        /*
        // Temporary effect: flip chess
        // Do nothing if a flipping is ongoing
        if (isMoving) {
            return;
        }
        // Obtain necessary scripts and objects
        GameObject chessEntity = this.transform.Find("ChessEntity").gameObject;
        GameObject chessMask = this.transform.Find("ChessMask").gameObject;
        if (isWaiting)
        {
            // Kill floating sequence
            shakeChessSeq.Kill();
            // Get new starter
            bool newStarter = (chessEntity.transform.localRotation.y == 0.0f) ? false : true;
            // Change ChessMask active
            chessMask.SetActive(false);
            // Flip chess using DOTween sequence
            isMoving = true;
            Sequence moveChessSeq = DOTween.Sequence();
            moveChessSeq
                .Append(this.transform.DOLocalMove(new Vector3(-90, -90, HEIGHT), 0.5f)) // Move to target position
                .Append(chessEntity.transform.DOLocalRotateQuaternion(Quaternion.Euler(0, newStarter ? 0.0f : 180.0f, 0), 0.2f)) // Rotate
                .Append(this.transform.DOLocalMoveZ(0, 0.3f) // Go down
                .OnComplete(() =>
                {
                    // Reset isFlipping
                    isMoving = false;
                    // Reset ChessMask active
                    UpdateMaskActive();
                })
                );
            // End of waiting
            isWaiting = false;
        }
        else {
            // Change ChessMask active
            chessMask.SetActive(false);
            // Flip chess using DOTween sequence
            isMoving = true;
            Sequence floatChessSeq = DOTween.Sequence();
            floatChessSeq
                .Append(this.transform.DOLocalMoveZ(HEIGHT, 0.3f) // Go up
                .OnComplete(() =>
                {
                    // Reset isFlipping
                    isMoving = false;
                    // Reset ChessMask active
                    UpdateMaskActive();

                    // Keep floating
                    shakeChessSeq = DOTween.Sequence();
                    shakeChessSeq
                        .Append(this.transform.DOLocalMoveZ(HEIGHT + 30, 0.7f))
                        .SetLoops(-1, LoopType.Yoyo);
                })
                );
            // Start waiting
            isWaiting = true;
        }
        */
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        // No matter how, update the hovering flag
        isHovering = true;
        // Do nothing if an animation is ongoing
        if (GameManager.GetInAnimation())
        {
            return;
        }
        // Otherwise, render masks
        ChessController chess = this.GetComponent<ChessController>();
        chess.GetGameModel().RenderMask(isHovering, chess.GetIndex());
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        isHovering = false;
        // Render masks
        ChessController chess = this.GetComponent<ChessController>();
        chess.GetGameModel().RenderMask(isHovering, chess.GetIndex());
    }

}
