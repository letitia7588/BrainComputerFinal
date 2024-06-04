using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class fighter : MonoBehaviour
{

    [SerializeField] private Game game;
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
        if (col.tag == "enemy")
        {
            game.nowHeart -= 1;
            Destroy(col.gameObject);
            game.displayHeart();
        }
    }
}
