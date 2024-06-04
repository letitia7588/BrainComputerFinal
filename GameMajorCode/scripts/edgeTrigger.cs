using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class edgeTrigger : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    void OnTriggerEnter2D(Collider2D col)
    {
        if (col.tag == "bullet")
        {
            Destroy(col.gameObject);
        }
        if (col.tag == "enemy")
        {
            Destroy(col.gameObject);
        }
    }
}
