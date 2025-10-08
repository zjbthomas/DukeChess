using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace Michsky.DreamOS
{
    [DisallowMultipleComponent]
    [RequireComponent(typeof(GridLayoutGroup))]
    public class ItemDragContainer : MonoBehaviour
    {
        [Header("Resources")]
        public GridLayoutGroup gridLayoutGroup;
        public RectTransform dragBorder;

        [Header("Settings")]
        public DragMode dragMode = DragMode.FREE;

        public enum DragMode
        {
            SNAPPED,
            FREE
        }

        public GameObject objectBeingDragged { get; set; }
       
        void Awake()
        {
            objectBeingDragged = null;

            if (gridLayoutGroup == null)
                gridLayoutGroup = gameObject.GetComponent<GridLayoutGroup>();

            if (dragBorder == null)
                dragBorder = gameObject.GetComponent<RectTransform>();

            // Without this, object transform will be resetted
            StartCoroutine("ApplyDragMode");
        }

        public void FreeDragMode()
        {
            dragMode = DragMode.FREE;
            StartCoroutine("ApplyDragMode");
        }

        public void SnappedDragMode()
        {
            dragMode = DragMode.SNAPPED;
            StartCoroutine("ApplyDragMode");
        }

        IEnumerator ApplyDragMode()
        {
            yield return new WaitForSeconds(0.1f);

            if (dragMode == DragMode.FREE)
                gridLayoutGroup.enabled = false;
            else
                gridLayoutGroup.enabled = true;
        }
    }
}