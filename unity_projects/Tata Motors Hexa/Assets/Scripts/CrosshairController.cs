using UnityEngine;
using System.Collections;

public class CrosshairController : MonoBehaviour 
{
	// Singleton instance
	public static CrosshairController Instance;

	// public variables
	public Camera cameraFacing;

	// Use this for initialization
	void OnEnable () 
	{
		Instance = this;
	}
	
	// Update is called once per frame
	void Update () 
	{
		transform.position = cameraFacing.transform.position + cameraFacing.transform.rotation * Vector3.forward;
		transform.LookAt (cameraFacing.transform.position);
	}
}
