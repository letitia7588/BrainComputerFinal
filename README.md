# ISA557300 BCI Final Project
Authors: 111064514 柯昱鈴 112062674 羅士軒 112065501 簡辰穎

## Introduction

### Overview

- Our BCI system uses EEG signals to classify emotions during gameplay, aiming to adjust game difficulty in real-time. We focus on detecting emotions such as boring, calm, horror, and funny. Using the GAMEEMO dataset, which includes EEG data from 28 subjects playing games designed to trigger these emotions, our system features real-time emotion detection and adaptive game difficulty. This enhances the gaming experience by dynamically responding to the player's emotional state.

### Data Description

- **Experimental Design/Paradigm:**

    The **GAMEEMO** dataset involved 28 subjects playing four different computer games designed to trigger specific emotions (boring, calm, horror, and funny) for 5 minutes each, resulting in 20 minutes of EEG data per subject.

- **Procedure for Collecting Data:**

    Subjects wore the EMOTIV EPOC+ EEG device while playing each game for 5 minutes. After each game, they filled out a SAM (Self-Assessment Manikin) form to rate their emotional experiences.
    
- **Hardware and Software Used:**

    - EEG Device: EMOTIV EPOC+ (14-channel)
    - Software: EMOTIV PRO License
    - Computer Specifications:
        - Intel Core i7-4710MQ processor, 16 GB RAM, 16 GB GTX980M Graphic Card, Windows OS

- **Data Size:**

    - 28 subjects, 20 minutes of EEG data per subject
    - Total: 1568 EEG data points (4 games x 14 channels x 28 subjects)
    - Formats: .csv and .mat
    - Number of Channels:14 EEG channels
    - Sampling Rate: Original: 2048 Hz -> Downsampled: 128 Hz
    
- **Data Source:**

    - The dataset is publicly available from researchers at Kirklareli University and Firat University, Turkey.
    - We download it from Kaggle. [[link]](https://www.kaggle.com/datasets/sigfest/database-for-emotion-recognition-system-gameemo)
    
    
- **Quality Evaluation:**
    - Surveying and analyzing existing literature
        - The reason for choosing the GAMEEMO dataset is its prevalent use in recent EEG-based emotional classification studies, indicating its reliability for such research.[[2]](#ref2)[[3]](#ref3)[[4]](#ref4) We referenced [Khan and Rasool (2022)](#ref2) for our entire data preprocessing approach, aligning our steps with those learned from the course.
        - classifier:
        	- CNN: Unlike traditional machine learning methods, CNNs can be used on training data without manually extracted features. This leads to two situations:

				- Features may not be ignored by researchers.
				- Important features cannot be extracted from signal data in advance.
CNNs have been used to analyze emotion EEG signals in this paper [[5]](#ref5) and have achieved high accuracy.
        	- Decision Tree: Unlike Linear Regression and Logistic Regression, Decision Trees can classify complex datasets (e.g., type A data may be located both inside and outside of the other type of data, graphically speaking). If a Decision Tree model is overfitting, we can easily reduce the number of layers to resolve this issue. This method has been tried before to analyze other emotion EEG datasets [[6]](#ref6) and has achieved good results.
        	- KNN: KNN can be used to recognize data from n-dimensions into several classifications. The number of dimensions, n, is our feature count. K is the number of neighbors used to vote on the classification. In the paper [[7]](#ref7), the author used this method to classify people's emotion EEG data and achieved good results. Therefore, we apply it to our research.
        	- Gradient Boosting Classifier: The basis of the Boosting algorithm is to use weak learners (low complexity and low accuracy, e.g., one-layer decision trees) to generate a strong learner. This method has a benefit: weak learners are not easily overfitted, so the strong learner has this advantage as well. Gradient Boosting can be applied to different loss functions, such as regression. It creates a model to predict the residual between the weak learner and the expected result, then adds this to the weak learner. This process is repeated to ultimately create a strong learner. This method is also used to classify people's emotions, as described in paper[[8]](#ref8).

        

    - Analyzing the hidden independent components within EEG using ICA with ICLabel
    
      ![截圖 2024-05-31 凌晨12.29.47](https://hackmd.io/_uploads/Bk0iY7UVA.png)




## Model Framework

- The picture below is our BCI architecture

    ![截圖 2024-06-03 下午2.24.16](https://hackmd.io/_uploads/rkPj5Ei4C.png =700x)
    
- Input/Output Mechanisms:
    - Input: Raw EEG data collected from subjects using the EMOTIV EPOC+ EEG device.
    - Output: Emotion classifications and corresponding feature sets.
- Signal Preprocessing Techniques:
    - We applied a bandpass filter to limit signal frequencies between 1 and 50 Hz. This was followed by artifact signal removal using the Artifact Subspace Reconstruction (ASR) method.
- Data Segmentation Methods:
    - EEG data is segmented into 512-sample windows with 256-sample overlaps to capture both transient and steady-state features effectively.
- Feature Extraction Approaches:
    - We proceeded with feature extraction, referencing [Khan and Rasool (2022)](#ref2). The features were categorized into three domains, as shown in the table below:
        
    ![截圖 2024-06-03 下午1.53.46](https://hackmd.io/_uploads/By1c5Rq4A.png)
- Classification

  After transforming the data, we applied three different machine learning models and CNN model to classify the emotions:
  
    * **CNN(training data is EEG signal)**
    	- CNN is usually used to classify images, but it can also be used to classify 1-D data. We can modify our original 2-D CNN model by converting its layers (convolution, pooling, etc.) from 2-D to 1-D. This will allow the model to achieve accuracy similar to that of a 2-D CNN model. For training, we split the original data (channel AF4) into 1 seconds segments, resulting in a total of 33,600 data.
    * **CNN(training data is frequency of EEG signal)**
		- As mentioned above, CNN can also be used on frequency domain data because both are 1-D. Therefore, we applied this method to the frequency data of 1-second EEG signals that were separated from the original 5-minute data (channel AF4), resulting in a total of 33,600 data points.
    * **Gradient Boosting**
        * Gradient Boosting is an ensemble learning method that builds multiple decision trees sequentially to improve the model's performance.
    * **K-Nearest Neighbors (KNN)**
        * KNN is a simple, non-parametric method used for classification that relies on the distance between data points in feature space.
    * **Decision Tree**
        * A Decision Tree is a model that splits the data into branches to represent the decisions and their possible consequences, including outcomes.
    
    For the three machine learning models, we compare the differences with data from specific channel and hybrid features to all the channel and features.
    
    The hybrid features are shown in the below table[[2]](#ref2):
    
    ![螢幕擷取畫面 2024-06-04 230835](https://hackmd.io/_uploads/Ska66a24R.png)
    
    The reason of choosing hybrid data is that it is proved to have higher importance[[2]](#ref2).

    
    The data was divided into training and testing sets with a 6:4 split.

    




## Validation
 - **CNN**
 	- Maxpooling layer
 		- It can be used to extract certain features and reduce the dataset to accelerate convergence. However, in some situations, it may lose some data and decrease the accuracy rate. In our dataset, it performs well without using pooling layer, improving the accuracy of both the training set and the test set.
 		- Without maxpooling layer
			![image](https://hackmd.io/_uploads/r14fVSAEA.png)
		- With maxpooling layer(window size = 2)
			![image](https://hackmd.io/_uploads/rkZiRNANR.png)

 	- Dropout layer
 		- It can be used to resolve the overffting issue
 			- Without dropout layer
 			![image](https://hackmd.io/_uploads/By70p4CER.png)
 			- With dropout layer(dropout rate = 0.1)
 			![image](https://hackmd.io/_uploads/rkxJpNRER.png)
 - **Machine Learning Method**
 
    * K-fold cross validation
    Cross-validation is a resampling technique used to evaluate machine learning models by splitting the dataset into multiple subsets (folds), training the model on a subset, and evaluating it on the remaining subsets.
    ![image](https://hackmd.io/_uploads/r13I6XJB0.png)


## Usage

```
To run CNN model:
	1. download data from kaggle(https://www.kaggle.com/datasets/sigfest/database-for-emotion-recognition-system-gameemo)
	2. python version: Python 3.9.12
	3. pip install packages: pandas, numpy, matplotlib, scipy, random, keras, tensorflow, sklearn, itertools
	4. run "CNN use EEG signal to train.ipynb" and "CNN use fft of EEG to train.ipynb" file that in our github
	
To run EEG_signal_preprocess.m:
    please install Signal Processing Toolbox and Wavelet Toolbox first.

To run dataprocess.py, gradient_boosting_classifier.py, decision_tree_classifier.py, KNN_classifier.py, user can run directly (ex:py KNN_classifier.py )
```

 - **CNN**
 	- Use two size 3 filter of convolution layer to replace size 5 filter
 		- This can improve convolution efficiency without a decrease in effectiveness.
 		 ![image](https://hackmd.io/_uploads/ByEEbH0VC.png)

 	- maxpooling layer
 		- As the results shown above, we found that the model can achieve better performance without using maxpooling layer. Therefore, we did not use maxpooling layer in our model.

 	- dropout layer
 		- We found that adding a dropout layer effectively reduces overfitting, so we incorporated a dropout layer into our model.
	- model summary:
 	![image](https://hackmd.io/_uploads/HJdDsGyHA.png)

## Results
 - **CNN(training data is EEG signal)**
  	- accuracy: 0.570
 ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/219c415c-0593-4b3a-aa4a-f38e0fe42223)


 	- precision: 0.5697314293373466
	- recall: 0.5695850329352139
	- F1-score: 0.5696160462000721
	- confusion_matrix:
	![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/5d7ee157-b53b-46cc-a7e5-989b8df047ec)


	
 - **CNN(training data is frequency of EEG signal)**
  	- accuracy: 0.398
  	(We found that the accuracy rate decreases as the number of subjects increases. This is because, as the number of subjects increases, data discrepancy becomes more pronounced. Below is the accuracy for different numbers of subjects.)
	![image](https://hackmd.io/_uploads/ryxcHm1SA.png)
	![image](https://hackmd.io/_uploads/BkAPUQJBC.png)
	![image](https://hackmd.io/_uploads/BkFfimyH0.png)


 	- precision: 0.398350919370576
	- recall: 0.3979694160429126
	- F1-score: 0.3980683968759325
	- confusion_matrix: 
![image](https://hackmd.io/_uploads/H11P27yrR.png)

 - **Machine Learning Model** 

   ![image](https://hackmd.io/_uploads/ByRkIzyrR.png)


   The results is shown in the above table. We can found that the Gradient Boosting model performed the best among the three models. Specifically, with hybrid features from all channels achieved the highest performance with an accuracy of 0.58 on the raw data. The Decision Tree performed better with all features from all channels, achieving a precision of 0.56 on the raw data. Lastly, KNN achieved a performance of 0.38 with hybrid features from the specific channel type on the raw data.
    On the other hand, for all the emotion classes, we found out that boring was classified the best among all the classes with 0.42 of precision, while horror was the worst, only achives 0.3.  
    
    The following tables show the thorough accuracy of each model, the classifiction precision of each emotion class (0.4 is the ratio of the testing set), and the confusion matrix :
    
    * **Gradient Boosting**
    
    ![image](https://hackmd.io/_uploads/BJKEk334R.png)
    
    ![image](https://hackmd.io/_uploads/Hkc_B2hEA.png)
    
    ![Gradient_Boosting](https://hackmd.io/_uploads/rkXf-7JrC.png)

    * **Decision Tree**
    
    ![image](https://hackmd.io/_uploads/BycUe33VA.png)
    
    ![image](https://hackmd.io/_uploads/SkryIhnN0.png)
    
    ![Decision_Tree](https://hackmd.io/_uploads/HJQ-mXkr0.png)


    * **KNN**
    
    ![image](https://hackmd.io/_uploads/ByGgJn24A.png)
    
    ![image](https://hackmd.io/_uploads/BkW8fp3VC.png)
    
    ![KNN](https://hackmd.io/_uploads/Bkfm-XyS0.png)
    
 - Advantages and unique aspects 
    The following table shows the overall performance of the competing model from [[2]](#ref2) :
    ![螢幕擷取畫面 2024-06-06 202257](https://hackmd.io/_uploads/Syf2qX1HA.png)
    ![螢幕擷取畫面 2024-06-06 202306](https://hackmd.io/_uploads/SyznqmJHR.png)
    ![image](https://hackmd.io/_uploads/HJ9JiXkSR.png)


    Our system, while not achieving top-tier accuracy, showcases our thorough exploration of various features, machine learning models, and deep learning techniques.From the observation with confusion matrix, we found out that some EEG data are easily mixed with others, such as calm and funny. Their EEG data may have something in common. 
    On the other hand, we've developed a game that can adjust the difficuties by classifying the players' emotion in time.


## References
<a id="ref1"></a>[1] Alakus, T. B., Gonen, M., & Turkoglu, I. (2020). Database for an emotion recognition system based on EEG signals and various computer games–GAMEEMO. Biomedical Signal Processing and Control, 60, 101951. [[pdf]](https://reurl.cc/NQNo2p)

<a id="ref2"></a>[2] Khan, A., & Rasool, S. (2022). Game induced emotion analysis using electroencephalography. Computers in Biology and Medicine, 145, 105441.[[pdf]](https://www.sciencedirect.com/science/article/abs/pii/S0010482522002335?via%3Dihub)

<a id="ref3"></a>[3] Abdulrahman, A., Baykara, M., & Alakus, T. B. (2022). A novel approach for emotion recognition based on EEG signal using deep learning. Applied Sciences, 12(19), 10028.[[pdf]](https://www.mdpi.com/2076-3417/12/19/10028)

<a id="ref4"></a>[4] Alakus, T. B., & Turkoglu, I. J. E. L. (2020). Emotion recognition with deep learning using GAMEEMO data set. Electronics Letters, 56(25), 1364-1367.[[pdf]](https://ietresearch.onlinelibrary.wiley.com/doi/10.1049/el.2020.2460)

<a id="ref5"></a>[5] Suat Toraman and Ömer Osman Dursun.(2021).GameEmo-CapsNet: Emotion Recognition from Single-Channel EEG Signals Using the 1D Capsule Networks[[pdf]](https://www.researchgate.net/publication/357772057_GameEmo-CapsNet_Emotion_Recognition_from_Single-Channel_EEG_Signals_Using_the_1D_Capsule_Networks)

<a id="ref6"></a>[6] Rafal Chalupnik, Katarzyna Bialas, Zofia Majewska & Michal Kedziora.(2022).Using Simplified EEG-Based Brain Computer Interface and Decision Tree Classifier for Emotions Detection[[pdf]](https://link.springer.com/chapter/10.1007/978-3-030-99587-4_26)

<a id="ref7"></a>[7] Shashank Joshi, Falak Joshi.(2021).HUMAN EMOTION CLASSIFICATION BASED ON EEG SIGNALS USING RECURRENT NEURAL NETWORK AND KNN[[pdf]](https://arxiv.org/abs/2205.08419)

<a id="ref8"></a>[8] Manish Manohare, E. Rajasekar, Manoranjan Parida.(2023).Electroencephalography based classification of emotions associated with road traffic noise using Gradient boosting algorithm[[pdf]](https://www.sciencedirect.com/science/article/abs/pii/S0003682X23001044)
