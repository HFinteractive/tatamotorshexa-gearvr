using UnityEngine;
using System.Collections;

public class ColorController : MonoBehaviour 
{
	// Singleton instance
	public static ColorController Instance;

	// public variables
	public Transform cameraEyeAnchor;
	public GameObject orange;
	public GameObject blue;
	public GameObject darkgrey;
	public GameObject lightgrey;
	public GameObject maroon;
	public GameObject white;

	// private variables
	bool isGridOpen;
	Vector3 pos;
	Vector3 iniPos1;
	Vector3 iniPos2;
	Vector3 iniPos3;
	Vector3 iniPos4;
	Vector3 iniPos5;
	Vector3 iniPos6;

	// Use this for initialization
	void OnEnable () 
	{
		Instance = this;

		isGridOpen = false;
		pos = Vector3.zero;
		iniPos1 = orange.transform.position;
		iniPos2 = blue.transform.position;
		iniPos3 = darkgrey.transform.position;
		iniPos4 = lightgrey.transform.position;
		iniPos5 = maroon.transform.position;
		iniPos6 = white.transform.position;
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
			if (hit.collider.gameObject.tag.Equals ("Grid"))
			{
				isGridOpen = true;

				MenuController.Instance.ResetMainMenu ();
				MenuController.Instance.DisableCollision ();
				ShowColorOptions ();

				Invoke ("UpdateMainMenu", 0.5f);
			}
			else if (hit.collider.gameObject.tag.Equals ("Color"))
			{
				ApplyColor (hit.collider.gameObject.name);
			}
		}
	}

	void ShowColorOptions ()
	{
		orange.SetActive (true);
		blue.SetActive (true);
		darkgrey.SetActive (true);
		lightgrey.SetActive (true);
		maroon.SetActive (true);
		white.SetActive (true);

		LeanTween.moveX (blue, blue.transform.position.x - 6.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
		LeanTween.moveX (orange, orange.transform.position.x - 4.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
		LeanTween.moveX (lightgrey, lightgrey.transform.position.x - 2.0f, 0.5f).setEase (LeanTweenType.easeOutSine);

		LeanTween.moveX (white, white.transform.position.x + 0.5f, 0.5f).setEase (LeanTweenType.easeOutSine);
		LeanTween.moveX (darkgrey, darkgrey.transform.position.x + 2.3f, 0.5f).setEase (LeanTweenType.easeOutSine);
		LeanTween.moveX (maroon, maroon.transform.position.x + 4.1f, 0.5f).setEase (LeanTweenType.easeOutSine);

		Invoke ("EnableCollision", 0.5f);
	}

	void ApplyColor (string vehicleName)
	{
		MeshRenderer[] mra = ApplicationManager.Instance.vehicle.GetComponentsInChildren<MeshRenderer>();
		for (int i = 0; i<mra.Length; i++)
		{
			Material[] ma = mra[i].GetComponent<MeshRenderer>().materials;
			for (int j = 0; j<ma.Length; j++)
			{
				if (ma[j].name.Equals ("dbl_skp6854_002 (Instance)"))
				{
					switch (vehicleName)
					{
					case "orange":
						ma[j].color = new Color (1.0f, 0.271f, 0.0f, 1.0f);
						break;

					case "blue":
						ma[j].color = new Color (0.192f, 0.31f, 0.31f, 1.0f);
						break;

					case "darkgrey":
						ma[j].color = new Color (0.294f, 0.294f, 0.294f, 1.0f);
						break;

					case "lightgrey":
						ma[j].color = new Color (0.827f, 0.827f, 0.827f, 1.0f);
						break;

					case "maroon":
						ma[j].color = new Color (0.698f, 0.133f, 0.133f, 1.0f);
						break;

					case "white":
						ma[j].color = new Color (1.0f, 1.0f, 1.0f, 1.0f);
						break;
					}
				}
			}
		}
	}

	public void ResetColor ()
	{
		MeshRenderer[] mra = ApplicationManager.Instance.vehicle.GetComponentsInChildren<MeshRenderer>();
		for (int i = 0; i<mra.Length; i++)
		{
			Material[] ma = mra[i].GetComponent<MeshRenderer>().materials;
			for (int j = 0; j<ma.Length; j++)
			{
				if (ma[j].name.Equals ("dbl_skp6854_002 (Instance)"))
				{
					switch (ApplicationManager.Instance.vehicleName)
					{
					case "Volkswagen Polo GTI Mk5":
						ma[j].color = new Color (0.694f, 0.027f, 0.051f, 1.0f);
						break;

					case "Subaru BRZ FA20":
						ma[j].color = new Color (0.265f, 0.369f, 0.801f, 1.0f);
						break;

					case "BMW X5 4.8i E70":
						ma[j].color = new Color (0.691f, 0.691f, 0.691f, 1.0f);
						break;
					}
				}
			}
		}
	}

	void EnableCollision ()
	{
		orange.GetComponent<BoxCollider>().enabled = true;
		blue.GetComponent<BoxCollider>().enabled = true;
		darkgrey.GetComponent<BoxCollider>().enabled = true;
		lightgrey.GetComponent<BoxCollider>().enabled = true;
		maroon.GetComponent<BoxCollider>().enabled = true;
		white.GetComponent<BoxCollider>().enabled = true;
	}

	void DisableCollision ()
	{
		orange.GetComponent<BoxCollider>().enabled = false;
		blue.GetComponent<BoxCollider>().enabled = false;
		darkgrey.GetComponent<BoxCollider>().enabled = false;
		lightgrey.GetComponent<BoxCollider>().enabled = false;
		maroon.GetComponent<BoxCollider>().enabled = false;
		white.GetComponent<BoxCollider>().enabled = false;
	}

	public void CheckColorGridStatus ()
	{
		if (isGridOpen)
		{
			ResetColorGrid ();

			isGridOpen = false;
		}
	}

	void ResetColorGrid ()
	{
		orange.SetActive (false);
		blue.SetActive (false);
		darkgrey.SetActive (false);
		lightgrey.SetActive (false);
		maroon.SetActive (false);
		white.SetActive (false);

		orange.transform.position = iniPos1;
		blue.transform.position = iniPos2;
		darkgrey.transform.position = iniPos3;
		lightgrey.transform.position = iniPos4;
		maroon.transform.position = iniPos5;
		white.transform.position = iniPos6;

		GameObject.Find ("_MC").GetComponent<BoxCollider>().enabled = true;
	}

	void UpdateMainMenu ()
	{
		MenuController.Instance.EnableCollision ();
	}
}