using UnityEngine;
using System.Collections;

public class MenuController : MonoBehaviour 
{
	// Singleton instance
	public static MenuController Instance;

	// public variables
	public Transform cameraEyeAnchor;
	public GameObject swap;
	public GameObject interior;
	public GameObject home;
	public GameObject information;
	public GameObject video;
	public GameObject grid;
	public GameObject mc;

	// private variables
	bool isMenuOpen;
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

		isMenuOpen = false;
		pos = Vector3.zero;
		iniPos1 = swap.transform.position;
		iniPos2 = interior.transform.position;
		iniPos3 = home.transform.position;
		iniPos4 = information.transform.position;
		iniPos5 = video.transform.position;
		iniPos6 = grid.transform.position;

		Invoke ("EnableCollision", 1.0f);
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
			if (hit.collider.gameObject.tag.Equals ("Menu"))
			{
				ControlMenuOptions ();
				ColorController.Instance.CheckColorGridStatus ();
			}
		}
	}

	void ControlMenuOptions ()
	{
		if (!isMenuOpen)
		{
			interior.SetActive (true);
			swap.SetActive (true);
			home.SetActive (true);
			information.SetActive (true);
			video.SetActive (true);
			grid.SetActive (true);

			LeanTween.moveX (interior, interior.transform.position.x + 2.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
			LeanTween.moveX (grid, grid.transform.position.x + 4.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
			LeanTween.moveX (video, video.transform.position.x + 6.0f, 0.5f).setEase (LeanTweenType.easeOutSine);

			LeanTween.moveX (swap, swap.transform.position.x - 2.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
			LeanTween.moveX (home, home.transform.position.x - 4.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
			LeanTween.moveX (information, information.transform.position.x - 6.0f, 0.5f).setEase (LeanTweenType.easeOutSine);

			DisableCollision ();
			Invoke ("EnableCollision", 0.5f);

			isMenuOpen = true;
		}
		else
		{
			LeanTween.moveX (interior, interior.transform.position.x - 2.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
			LeanTween.moveX (grid, grid.transform.position.x - 4.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
			LeanTween.moveX (video, video.transform.position.x - 6.0f, 0.5f).setEase (LeanTweenType.easeOutSine);

			LeanTween.moveX (swap, swap.transform.position.x + 2.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
			LeanTween.moveX (home, home.transform.position.x + 4.0f, 0.5f).setEase (LeanTweenType.easeOutSine);
			LeanTween.moveX (information, information.transform.position.x + 6.0f, 0.5f).setEase (LeanTweenType.easeOutSine);

			DisableCollision ();
			Invoke ("ResetMainMenu", 0.5f);
		}	
	}

	public void EnableCollision ()
	{
		interior.GetComponent<BoxCollider>().enabled = true;
		swap.GetComponent<BoxCollider>().enabled = true;
		home.GetComponent<BoxCollider>().enabled = true;
		information.GetComponent<BoxCollider>().enabled = true;
		video.GetComponent<BoxCollider>().enabled = true;
		grid.GetComponent<BoxCollider>().enabled = true;
		mc.GetComponent<BoxCollider>().enabled = true;
	}

	public void DisableCollision ()
	{
		interior.GetComponent<BoxCollider>().enabled = false;
		swap.GetComponent<BoxCollider>().enabled = false;
		home.GetComponent<BoxCollider>().enabled = false;
		information.GetComponent<BoxCollider>().enabled = false;
		video.GetComponent<BoxCollider>().enabled = false;
		grid.GetComponent<BoxCollider>().enabled = false;
		mc.GetComponent<BoxCollider>().enabled = false;
	}

	public void ResetMainMenu ()
	{
		isMenuOpen = false;

		interior.SetActive (false);
		swap.SetActive (false);
		home.SetActive (false);
		information.SetActive (false);
		video.SetActive (false);
		grid.SetActive (false);

		swap.transform.position = iniPos1;
		interior.transform.position = iniPos2;
		home.transform.position = iniPos3;
		information.transform.position = iniPos4;
		video.transform.position = iniPos5;
		grid.transform.position = iniPos6;

		mc.GetComponent<BoxCollider>().enabled = true;
	}
}
