using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public static SoundManager soundManager;

    // Bound to UI
    public AudioSource bgmPrefab;
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

        bgm.Play();
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
