using UnityEngine;
using System.Collections;

public class CameraController : MonoBehaviour 
{
	// Singleton instance
	public static CameraController Instance;

	// public variables
	public Transform cameraEyeAnchor;
	public Transform ovrPlayerController;
	public Transform interiorReference1;
	public Transform interiorReference2;
	public Transform interiorReference3;
	public GameObject exteriorReference1;
	public GameObject exteriorReference2;
	public GameObject exteriorReference3;
	public GameObject cameraBlackPatch;
	public GameObject interior1;
	public GameObject interior2;
	public GameObject interior3;
	public GameObject exterior1;
	public GameObject exterior2;
	public GameObject exterior3;
	public GameObject menu;
	public bool isInsideAuto;

	// private variables
	bool isFadingIn;
	bool isFadingOut;
	float alpha;
	Vector3 pos;
	Vector3 initialPosition;
	MeshRenderer mr;

	// Use this for initialization
	void OnEnable () 
	{
		Instance = this;

		isFadingIn = isFadingOut = isInsideAuto = false;
		alpha = 0.0f;
		pos = Vector3.zero;
		initialPosition = ovrPlayerController.position;
		mr = cameraBlackPatch.GetComponent<MeshRenderer>();
	}

	// Update is called once per frame
	void Update () 
	{
		if (Input.GetMouseButtonDown (0))
		{
			pos = Input.mousePosition;
		}

		if (Input.GetMouseButtonUp (0)) 
		{
			var delta = Input.mousePosition-pos;

			if (delta == new Vector3 (0.0f, 0.0f, 0.0f))
			{
				CheckCollisions ();
			}
		}

		ControlFadeTransition ();
	}

	void CheckCollisions ()
	{
		Ray ray = new Ray (cameraEyeAnchor.position, -cameraEyeAnchor.forward);
		RaycastHit hit;

		if (Physics.Raycast (ray, out hit, 1<<8))
		{
			if (alpha.Equals (0.0f))
			{
				if (hit.collider.gameObject.tag.Equals ("Interior"))
				{
					if (!isInsideAuto)
					{
						isFadingIn = true;

						ovrPlayerController.gameObject.GetComponent<CharacterController>().enabled = false;

						MenuController.Instance.ResetMainMenu ();
						MenuController.Instance.DisableCollision ();
						InformationController.Instance.HideAllInformation ();
					}
				}
				else if (hit.collider.gameObject.tag.Equals ("Exterior"))
				{
					if (isInsideAuto)
					{
						isFadingIn = true;

						hit.collider.gameObject.SetActive (false);

						MenuController.Instance.EnableCollision ();
					}
				}
			}
		}
	}

	void ControlFadeTransition ()
	{
		if (isFadingIn)
		{
			mr.enabled = true;

			if (alpha < 1.0f)
			{
				alpha += 0.1f;
				mr.material.color = new Color (mr.material.color.r, mr.material.color.g, mr.material.color.b, alpha);
			}
			else 
			{
				SwitchCameraView ();

				isFadingIn = false;
				alpha = 1.0f;
			}
		}
		if (isFadingOut)
		{
			if (alpha > 0.0f)
			{
				alpha -= 0.1f;
				mr.material.color = new Color (mr.material.color.r, mr.material.color.g, mr.material.color.b, alpha);
			}
			else 
			{
				isFadingOut = false;
				alpha = 0.0f;

				mr.enabled = false;
			}
		}
	}

	void SwitchCameraView ()
	{
		isFadingOut = true;
		isInsideAuto = !isInsideAuto;

		if (isInsideAuto)
		{
			PrepareInteriorView ();
		}
		else
		{
			PrepareExteriorView ();
		}
	}

	void PrepareInteriorView ()
	{
		switch (ApplicationManager.Instance.vehicleName)
		{
		case "Volkswagen Polo GTI Mk5":
			interior1.SetActive (true);
			exterior1.SetActive (false);
			exteriorReference1.SetActive (true);

			ovrPlayerController.position = interiorReference1.position;
			ovrPlayerController.rotation = interiorReference1.rotation;
			break;

		case "Subaru BRZ FA20":
			interior2.SetActive (true);
			exterior2.SetActive (false);
			exteriorReference2.SetActive (true);

			ovrPlayerController.position = interiorReference2.position;
			ovrPlayerController.rotation = interiorReference2.rotation;
			break;

		case "BMW X5 4.8i E70":
			interior3.SetActive (true);
			exterior3.SetActive (false);
			exteriorReference3.SetActive (true);

			ovrPlayerController.position = interiorReference3.position;
			ovrPlayerController.rotation = interiorReference3.rotation;
			break;
		}

		menu.SetActive (false);
	}

	void PrepareExteriorView ()
	{
		switch (ApplicationManager.Instance.vehicleName)
		{
		case "Volkswagen Polo GTI Mk5":
			interior1.SetActive (false);
			exterior1.SetActive (true);
			break;

		case "Subaru BRZ FA20":
			interior2.SetActive (false);
			exterior2.SetActive (true);
			break;

		case "BMW X5 4.8i E70":
			interior3.SetActive (false);
			exterior3.SetActive (true);
			break;
		}

		ovrPlayerController.position = initialPosition;
		ovrPlayerController.rotation = Quaternion.identity;
		ovrPlayerController.gameObject.GetComponent<CharacterController>().enabled = true;

		menu.SetActive (true);
	}
}
