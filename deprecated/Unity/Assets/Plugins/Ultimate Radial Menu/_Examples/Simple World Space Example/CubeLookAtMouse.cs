/* CubeLookAtMouse.cs */
/* Written by Kaz Crowe */
using UnityEngine;

public class CubeLookAtMouse : MonoBehaviour
{
	public Transform cameraTransform;

	void Update ()
	{
		transform.LookAt( cameraTransform.position + ( new Vector3( -( ( Screen.width / 2 ) - Input.mousePosition.x ) / Screen.width, -( ( Screen.height / 2 ) - Input.mousePosition.y ) / Screen.height, 0.1f ) * 15 ) );
	}
}