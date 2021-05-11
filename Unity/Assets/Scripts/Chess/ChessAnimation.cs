using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChessAnimation : MonoBehaviour
{
    public enum AnimationType {
        Generate,
        Destroy,
        Select,
        Move
    }

    // Constants
    private const int HEIGHT = -150;
    private const float SHAKELEVEL = 0.07f;
    
    // Bound to UI
    public ParticleSystem generate;
    public ParticleSystem destroy;

    private Sequence shakeChessSeq;

    private int swapPos;

    public void PlayAnimation(AnimationType type, int pos = -1) {
        // No matter how, hold on for animation, and always kill shakeChessSeq
        GameManager.SetInAnimation(true);
        shakeChessSeq.Kill();
        // Play animation depending on type
        switch (type) {
            case AnimationType.Generate:
                // Play sound
                SoundManager.soundManager.PlaySummonSound();

                // Show particles 
                PlayParticleSystem(generate);

                GameManager.SetInAnimation(false);
                break;
            case AnimationType.Destroy:
                // Play sound
                SoundManager.soundManager.PlayDestroySound();

                // Show particles
                PlayParticleSystem(destroy);

                // Shake camera
                Camera viewer = Camera.main;
                Sequence cameraShakeSeq = DOTween.Sequence();
                cameraShakeSeq
                    .Append(viewer.DORect(RandShakeRect(), 0.1f))
                    .Append(viewer.DORect(RandShakeRect(), 0.1f))
                    .Append(viewer.DORect(new Rect(0.0f, 0.0f, 1, 1), 0.1f))
                    .OnComplete(() => {
                        GameManager.SetInAnimation(false);
                    });
                break;
            case AnimationType.Select:
                Sequence floatChessSeq = DOTween.Sequence();
                floatChessSeq
                    .Append(this.transform.DOLocalMoveZ(HEIGHT, 0.3f)) // Go up
                    .OnComplete(() =>
                    {
                        GameManager.SetInAnimation(false);
                        // Keep floating
                        shakeChessSeq = DOTween.Sequence();
                            shakeChessSeq
                                .Append(this.transform.DOLocalMoveZ(HEIGHT + 30, 0.7f))
                                .SetLoops(-1, LoopType.Yoyo);
                    });
                break;
            case AnimationType.Move:
                if (pos == -1) {
                    return;
                }

                // Obtain necessary scripts and objects
                GameObject chessEntity = this.transform.Find("ChessEntity").gameObject;
                GameObject chessMask = this.transform.Find("ChessMask").gameObject;
                ChessController chess = this.GetComponent<ChessController>();
                
                // Change ChessMask active
                chessMask.SetActive(false);
                // Calculate target position
                Vector3 targetSky = ChessController.Index2Vec(pos);
                targetSky.z = HEIGHT;
                // Move chess using DOTween sequence
                Sequence moveChessSeq = DOTween.Sequence();
                moveChessSeq
                    .Append(this.transform.DOLocalMove(targetSky, 0.5f)) // Move to target position
                    .Append(chessEntity.transform.DOLocalRotateQuaternion(Quaternion.Euler(0, chess.GetChessData().GetStarter() ? 180.0f : 0.0f, 0), 0.2f)) // Rotate, notice the starter is the old one
                    .Append(this.transform.DOLocalMoveZ(0, 0.3f)) // Go down
                    .OnComplete(() =>
                    {

                        GameManager.SetInAnimation(false);

                        // Swap chess index
                        ChessController temp = chess.GetGameModel().GetBoard()[pos];
                        int tempPos = chess.GetIndex();
                        chess.GetGameModel().GetBoard()[pos] = chess;
                        chess.GetGameModel().GetBoard()[tempPos] = temp;

                        chess.SetIndex(pos);
                        temp.SetIndex(tempPos);

                        temp.transform.localPosition = ChessController.Index2Vec(tempPos);

                        if (temp.GetChessData() != null)
                        {
                            chess.gameObject.GetComponent<ChessAnimation>().PlayAnimation(AnimationType.Destroy);
                            temp.DestoryChess();
                        }
                        else {
                            // Play sound
                            SoundManager.soundManager.PlayMoveSound();
                        }

                    });
                break;
        }
    }

    public void PlayParticleSystem(ParticleSystem sysPrefab) {
        ParticleSystem sys = Instantiate(sysPrefab, new Vector3(0, 0, 0), Quaternion.identity);
        // Add sys to chess
        sys.transform.SetParent(this.transform);
        // Reset transform and scale, respect to chess
        sys.transform.localPosition = new Vector3(0, 0, -200);
        sys.transform.localScale = new Vector3(1, 1, 1);

        sys.Play();

        // No Destroy is called, need to set the Prefab's Stop Action to Destroy
    }

    private Rect RandShakeRect()
    {
        float x = SHAKELEVEL * (2.0f * Random.value - 1.0f);
        float y = SHAKELEVEL * (2.0f * Random.value - 1.0f);
        return new Rect(x, y, 1, 1);
    }
}
