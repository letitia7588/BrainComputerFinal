using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class enemy : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        gameObject.transform.position += new Vector3(0, -0.01f, 0);
    }
    void OnTriggerEnter2D(Collider2D col) //�W��col��Ĳ�o�ƥ�
    {
        if (col.tag == "bullet")
        {
            Destroy(col.gameObject); //�����I��������
            Destroy(gameObject); //�������󥻨�
        }
    }
}
