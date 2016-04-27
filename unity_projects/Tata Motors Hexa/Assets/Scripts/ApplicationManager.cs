using UnityEngine;
using System.Collections;
using UnityEngine.VR;

public class ApplicationManager : MonoBehaviour 
{
	// Singleton instance
	public static ApplicationManager Instance;

	// public variables
	public Transform cameraEyeAnchor;
	public GameObject cameraBlackPatch;
	public GameObject introductionManager;
	public GameObject experienceManager;
	public GameObject vehicle;
	public bool isExprLaunched;
	public string vehicleName;
	public int vehicleId;

	// private variables
	bool isFadingIn;
	bool isFadingOut;
	float alpha;
	Vector3 pos;
	MeshRenderer mr;
	GameObject[] ga;

	// Use this for initialization
	void OnEnable () 
	{
		//VRSettings.renderScale = 2.0f;
		Cursor.visible = false;

		Instance = this;

		isExprLaunched = isFadingIn = isFadingOut = false;
		alpha = 0.0f;
		pos = Vector3.zero;
		mr = cameraBlackPatch.GetComponent<MeshRenderer>();
	}

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
			if (hit.collider.gameObject.tag.Equals ("Intro"))
			{
				isFadingIn = true;
			}
			else if (hit.collider.gameObject.tag.Equals ("Home"))
			{
				isFadingIn = true;

				MenuController.Instance.ResetMainMenu ();
				MenuController.Instance.DisableCollision ();
				InformationController.Instance.HideAllInformation ();
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
				alpha += 0.03f;
				mr.material.color = new Color (mr.material.color.r, mr.material.color.g, mr.material.color.b, alpha);
			}
			else 
			{
				SwitchScenes ();

				isFadingIn = false;
				alpha = 1.0f;
			}
		}
		if (isFadingOut)
		{
			if (alpha > 0.0f)
			{
				alpha -= 0.03f;
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

	void SwitchScenes ()
	{
		isFadingOut = true;

		if (!experienceManager.activeSelf)
		{
			isExprLaunched = true;

			introductionManager.SetActive (false);
			experienceManager.SetActive (true);

			AssignVehicleInformation ();
		}
		else
		{
			isExprLaunched = false;

			introductionManager.SetActive (true);
			experienceManager.SetActive (false);
		}
	}

	public void AssignVehicleInformation ()
	{
		ga = GameObject.FindGameObjectsWithTag ("Vehicle");
		foreach (GameObject go in ga)
		{
			if (go.activeSelf)
			{
				vehicle = go;
				vehicleName = go.name;

				switch (vehicleName)
				{
				case "Volkswagen Polo GTI Mk5":
					vehicleId = 0;
					break;

				case "Subaru BRZ FA20":
					vehicleId = 1;
					break;

				case "BMW X5 4.8i E70":
					vehicleId = 2;
					break;
				}
			}
		}
	}
}
