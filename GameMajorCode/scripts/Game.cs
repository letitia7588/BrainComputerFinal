using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class Game : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI timeText, moodText;
    [SerializeField] private GameObject boring, calm, funny, horror;
    [SerializeField] private GameObject heart1, heart2, heart3;
    [SerializeField] private GameObject Bullet;
    [SerializeField] private GameObject enemy;
    [SerializeField] private GameObject blood;

    public int nowHeart = 3;
    int time = 0;
    int createEnemyCount = 1;
    bool nearBlood = false;
    List<int> moodList = new List<int> { 4, 4, 4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4};

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(countTime());
        StartCoroutine(createEnemy());
        StartCoroutine(displayEmotion());
        StartCoroutine(displayBlood());
    }

    // Update is called once per frame
    void Update()
    {
        //modified fighter position
        if (Input.GetKey("up"))
        {
            gameObject.transform.position += new Vector3(0, 0.03f, 0);
        }
        if (Input.GetKey("down"))
        {
            gameObject.transform.position += new Vector3(0, -0.03f, 0);
        }
        if (Input.GetKey("right"))
        {
            gameObject.transform.position += new Vector3(0.03f, 0, 0);
        }
        if (Input.GetKey("left"))
        {
            gameObject.transform.position += new Vector3(-0.03f, 0, 0);
        }

        //press space shoot bullet
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Vector3 pos = gameObject.transform.position + new Vector3(0, 0.6f, 0);

            Instantiate(Bullet, pos, gameObject.transform.rotation);
        }

    }

    IEnumerator countTime()
    {
        while (true)
        {
            //refresh time
            timeText.text = "survived time: " + string.Format("{0:00} : {1:00}", time / 60, time % 60);
            time++;

            yield return new WaitForSecondsRealtime(1);
        }
    }
    IEnumerator createEnemy()
    {
        while (true)
        {
            //create a enemy
            for (int i = 0; i < createEnemyCount; i++)
            {
                Vector3 enemyPos = new Vector3(Random.Range(-8f, 8f), 2.3f, 0); //宣告位置pos，Random.Range(-2.5f,2.5f)代表X是2.5到-2.5之間隨機
                Instantiate(enemy, enemyPos, transform.rotation);//產生敵人
            }

            yield return new WaitForSecondsRealtime(2);
        }
    }
    IEnumerator displayEmotion()
    {
        int emotionIndex = 0;
        while (true)
        {
            if (moodList[emotionIndex] == 1)
            {
                moodText.text = "(boring)";
                if (createEnemyCount <= 5)
                    createEnemyCount++;
                nearBlood = false;
                boring.GetComponent<SpriteRenderer>().enabled = true;
                calm.GetComponent<SpriteRenderer>().enabled = false;
                funny.GetComponent<SpriteRenderer>().enabled = false;
                horror.GetComponent<SpriteRenderer>().enabled = false;
            }
            if (moodList[emotionIndex] == 2)
            {
                moodText.text = "(calm)";
                boring.GetComponent<SpriteRenderer>().enabled = false;
                calm.GetComponent<SpriteRenderer>().enabled = true;
                funny.GetComponent<SpriteRenderer>().enabled = false;
                horror.GetComponent<SpriteRenderer>().enabled = false;
            }
            if (moodList[emotionIndex] == 3)
            {
                moodText.text = "(funny)";
                boring.GetComponent<SpriteRenderer>().enabled = false;
                calm.GetComponent<SpriteRenderer>().enabled = false;
                funny.GetComponent<SpriteRenderer>().enabled = true;
                horror.GetComponent<SpriteRenderer>().enabled = false;
            }
            if (moodList[emotionIndex] == 4)
            {
                moodText.text = "(horror)";
                if (createEnemyCount > 1)
                    createEnemyCount--;
                nearBlood = true;
                boring.GetComponent<SpriteRenderer>().enabled = false;
                calm.GetComponent<SpriteRenderer>().enabled = false;
                funny.GetComponent<SpriteRenderer>().enabled = false;
                horror.GetComponent<SpriteRenderer>().enabled = true;
            }

            emotionIndex += 1;
            yield return new WaitForSecondsRealtime(2);
        }
    }
    IEnumerator displayBlood()
    {
        float x1, x2, y1, y2;
        List<GameObject> a = new List<GameObject>();
        while (true)
        {
            //create a blood
            for (int i = 0; i < 5; i++)
            {
                if(nearBlood)
                {
                    x1 = gameObject.transform.position.x + 2;
                    x2 = gameObject.transform.position.x - 2;
                    y1 = gameObject.transform.position.y + 2;
                    y2 = gameObject.transform.position.y - 2;
                }
                else
                {
                    x1 = 8f;
                    x2 = -8f;
                    y1 = 4f;
                    y2 = -4f;
                }
                Vector3 bloodPos = new Vector3(Random.Range(x2, x1), Random.Range(y2, y1), 0);
                a.Add(Instantiate(blood, bloodPos, transform.rotation));
            }
            yield return new WaitForSecondsRealtime(5);

            //delete Blood
            for (int i = 0; i < 5; i++)
            {
                Destroy(a[i].gameObject);
            }
            a = new List<GameObject>();
            yield return new WaitForSecondsRealtime(1);
        }
    }
    public void displayHeart()
    {
        if (nowHeart == 0)
        {
            ; //display resart windows
        }
        if (nowHeart == 1)
        {
            heart1.GetComponent<SpriteRenderer>().enabled = true;
            heart2.GetComponent<SpriteRenderer>().enabled = false;
            heart3.GetComponent<SpriteRenderer>().enabled = false;
        }
        if (nowHeart == 2)
        {
            heart1.GetComponent<SpriteRenderer>().enabled = true;
            heart2.GetComponent<SpriteRenderer>().enabled = true;
            heart3.GetComponent<SpriteRenderer>().enabled = false;
        }
        if (nowHeart == 3)
        {
            heart1.GetComponent<SpriteRenderer>().enabled = true;
            heart2.GetComponent<SpriteRenderer>().enabled = true;
            heart3.GetComponent<SpriteRenderer>().enabled = true;
        }
    }
    void OnTriggerEnter2D(Collider2D col)
    {
        if (col.tag == "enemy")
        {
            if(nowHeart > 1)
                nowHeart -= 1;
            Destroy(col.gameObject);
            displayHeart();
        }
        if (col.tag == "blood")
        {
            if(nowHeart < 3)
                nowHeart += 1;
            Destroy(col.gameObject);
            displayHeart();
        }
    }
}
