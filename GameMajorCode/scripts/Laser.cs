using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Laser : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        gameObject.transform.position += new Vector3(0, 0.1f, 0);
    }
    void OnTriggerEnter2D(Collider2D col)
    {
        if (col.tag == "enemy")
        {
            Destroy(col.gameObject);
            Destroy(gameObject);
        }
    }
}
