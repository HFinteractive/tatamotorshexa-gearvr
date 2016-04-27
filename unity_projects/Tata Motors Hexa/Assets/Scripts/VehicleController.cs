using UnityEngine;
using System.Collections;

public class VehicleController : MonoBehaviour 
{
	// Singleton instance
	public static VehicleController Instance;

	// public variables
	public Transform cameraEyeAnchor;
	public GameObject automobile1;
	public GameObject automobile2;
	public GameObject automobile3;

	// private variables
	float speed;
	Vector3 pos;

	// Use this for initialization
	void OnEnable () 
	{
		Instance = this;

		speed = 60.0f;
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
			if (hit.collider.gameObject.tag.Equals ("Swap"))
			{
				if (ApplicationManager.Instance.vehicleId < 2)
				{
					ApplicationManager.Instance.vehicleId++;
				}
				else
				{
					ApplicationManager.Instance.vehicleId = 0;
				}

				automobile1.SetActive (false);
				automobile2.SetActive (false);
				automobile3.SetActive (false);

				switch (ApplicationManager.Instance.vehicleId)
				{
				case 0:
					automobile1.SetActive (true);
					break;

				case 1:
					automobile2.SetActive (true);
					break;

				case 2:
					automobile3.SetActive (true);
					break;
				}

				ResetRotation ();
				ColorController.Instance.ResetColor ();
				InformationController.Instance.HideAllInformation ();
				ApplicationManager.Instance.AssignVehicleInformation ();
			}
		}
	}

	public void HandleRotation (int rotationFactor)
	{
		transform.Rotate (new Vector3 (0.0f, 1.0f, 0.0f)  * Time.deltaTime * speed * rotationFactor);
	}

	void ResetRotation ()
	{
		transform.localEulerAngles = new Vector3 (0.0f, 0.0f, 0.0f);
	}
}
