using UnityEngine;
using System.Collections;

public class InformationController : MonoBehaviour 
{
	// Singleton instance
	public static InformationController Instance;

	// public variables
	public Transform cameraEyeAnchor;
	public GameObject infoText1;
	public GameObject infoText2;
	public GameObject infoText3;

	// private variables
	bool isVisible;
	Vector3 pos;

	// Use this for initialization
	void OnEnable () 
	{
		Instance = this;

		isVisible = false;
		pos = Vector3.zero;
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
	}

	void CheckCollisions ()
	{
		Ray ray = new Ray (cameraEyeAnchor.position, -cameraEyeAnchor.forward);
		RaycastHit hit;

		if (Physics.Raycast (ray, out hit, 1<<8))
		{
			if (hit.collider.gameObject.tag.Equals ("Info"))
			{
				ControlVehicleInformation ();
			}
		}
	}

	void ControlVehicleInformation ()
	{
		isVisible = !isVisible;

		switch (ApplicationManager.Instance.vehicleName)
		{
		case "Volkswagen Polo GTI Mk5":
			infoText1.SetActive (isVisible);
			break;

		case "Subaru BRZ FA20":
			infoText2.SetActive (isVisible);
			break;

		case "BMW X5 4.8i E70":
			infoText3.SetActive (isVisible);
			break;
		}
	}

	public void HideAllInformation ()
	{
		isVisible = false;

		infoText1.SetActive (false);
		infoText2.SetActive (false);
		infoText3.SetActive (false);
	}
}
