using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SoundManager : MonoBehaviour
{
    public static SoundManager soundManager;

    // Bound to UI
    public AudioSource bgmPrefab;
    public Button bgmPlayButton;
    public Button bgmStopButton;
    public Animator bgmControlAnimator;

    public AudioSource moveSoundPrefab;
    public AudioSource destroySoundPrefab;
    public AudioSource summonSoundPrefab;

    // private variables
    AudioSource bgm;
    AudioSource moveSound;
    AudioSource destroySound;
    AudioSource summonSound;

    

    void Start()
    {
        bgm = Instantiate(bgmPrefab);
        moveSound = Instantiate(moveSoundPrefab);
        destroySound = Instantiate(destroySoundPrefab);
        summonSound = Instantiate(summonSoundPrefab);

        // BGM related
        bgmPlayButton.onClick.AddListener(PlayBGM);
        bgmStopButton.onClick.AddListener(StopBGM);

        PlayBGM();
    }

    void PlayBGM() {
        bgmControlAnimator.Play("Pause In");
        bgm.Play();
    }

    void StopBGM()
    {
        bgmControlAnimator.Play("Play In");
        bgm.Stop();
    }

    void Awake()
    {
        if (soundManager == null)
        {
            soundManager = this;
        }
    }

    public void PlayMoveSound()
    {
        moveSound.Play();
    }

    public void PlayDestroySound() {
        destroySound.Play();
    }

    public void PlaySummonSound() {
        summonSound.Play();
    }
}
