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
        	- Decision tree: Decision tree not like Linear Regression, Logistic Regression cannot classified complex dataset(ex: type A data maybe located at both internal and external(Graphically speaking) of the other type data）. And if decision tree model is overfitting, we can easily decrease layers number to resolve. And to this method, someone have tried it to analysis other emotion EEG dataset before[[5]](#ref5) and get good achievement.(還沒檢查文法)
        	- KNN: KNN can be used to recongnize data from n-dimension to some classifications. Dimension number n is our feature count. And K is the neighbor count which are used to vote the classifition. In the paper [[6]](#ref6), Author used this method to classified people's emotion EEG data and get good achievemen. So we apply it to our research.(還沒檢查文法)
        	- Gradient Boosting Classifier: The basis of Boosting algorithm is used weak learner(low complexity and low accuracy, ex: one layer decision tree) to generate a strong learner. This method have a benifit: weak learner not easy to overfitting, so the strong learner have the advantage, too. And the Gradient Boosting can be apply on different loss function, for ex: regression. Create a model to predict the residual between weak learner and expected result. And then plus it to weak learner. Repeated above method. At last create a strong learner. This method be used to classified people's emotion, too. Paper: [[7]](#ref7)(還沒檢查文法)

        

    - Analyzing the hidden independent components within EEG using ICA with ICLabel
    
      ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/f87885ac-afa9-4b6c-9100-8158667c2123)






## Model Framework

- The picture below is our BCI architecture

    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/5afc10bd-12a0-4bb9-9bdd-e824b7c8f212)

    
- Input/Output Mechanisms:
    - Input: Raw EEG data collected from subjects using the EMOTIV EPOC+ EEG device.
    - Output: Emotion classifications and corresponding feature sets.
- Signal Preprocessing Techniques:
    - We applied a bandpass filter to limit signal frequencies between 1 and 50 Hz. This was followed by artifact signal removal using the Artifact Subspace Reconstruction (ASR) method.
- Data Segmentation Methods:
    - EEG data is segmented into 512-sample windows with 256-sample overlaps to capture both transient and steady-state features effectively.
- Feature Extraction Approaches:
    - We proceeded with feature extraction, referencing [Khan and Rasool (2022)](#ref2). The features were categorized into three domains, as shown in the table below:
        
    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/922078ba-13e1-4b05-bb39-6cb9de93472b)


  After transforming the data, we applied three different machine learning models to classify the emotions:

    * **Gradient Boosting**
        * Gradient Boosting is an ensemble learning method that builds multiple decision trees sequentially to improve the model's performance.
    * **K-Nearest Neighbors (KNN)**
        * KNN is a simple, non-parametric method used for classification that relies on the distance between data points in feature space.
    * **Decision Tree**
        * A Decision Tree is a model that splits the data into branches to represent the decisions and their possible consequences, including outcomes.
    
    As for the dataset, we compare the differences with data from specific channel and hybrid features to all the channel and features.
    
    The hybrid features are shown in the below table[[2]](#ref2):
    
    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/5a213ea0-0969-4242-925c-27d894116c72)

    
    The reason of choosing hybrid data is that it is proved to have higher importance[[2]](#ref2).

    
    The data was divided into training and testing sets with a 6:4 split.

- Evaluation

    The results show that the Gradient Boosting model performed the best among the three models. Specifically, with hybrid features from all channels achieved the highest performance with an accuracy of 0.58 on the raw data. The Decision Tree performed better with all features from all channels, achieving a precision of 0.56 on the raw data. Lastly, KNN achieved a performance of 0.38 with hybrid features from the specific channel type on the raw data.
    On the other hand, for all the emotion classes, we found out that boring was classified the best among all the classes with 0.42 of precision, while horror was the worst, only achives 0.3.  

    The following tables show the experiment results of each model and the classifiction precesion of each emotion class (0.4 is the ratio of the testing set) :
    
    * **Gradient Boosting**
    
    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/23a05592-9560-4e11-98f2-91861a57703e)

    
    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/fdb5e1e7-9875-4e53-bd7b-8077b41a6fc9)

    
    * **Decision Tree**
    
    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/bd51e9a4-4e17-402b-a9e3-46f9850b9715)

    
    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/9a7f9043-558c-407f-980e-16bf8792e6f4)

    
    * **KNN**
    
    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/434e061c-6548-4ac1-a602-483b0cf76f49)

    
    ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/a2428880-ce69-4725-8aed-bff9bebc168e)





## Validation

## Usage

## Results
 - F1 score
 	- (!!!put confusion matrix here)
 	- In this paper[[5]](#ref5), human emotions can be classified to 4 parts. X-axis indicates emotion positive or negative. And y-axis indicates the degree of activity. And the 4 classification will display more different to each other. Our results prove it well. (如果沒有證出這個結果那就刪掉XD)(還沒檢查文法)
 	- ![image](https://github.com/letitia7588/BrainComputerFinal/assets/170433140/d8339acf-6133-4997-bc65-2b59086f30d8)





## References
<a id="ref1"></a>[1] Alakus, T. B., Gonen, M., & Turkoglu, I. (2020). Database for an emotion recognition system based on EEG signals and various computer games–GAMEEMO. Biomedical Signal Processing and Control, 60, 101951. [[pdf]](https://reurl.cc/NQNo2p)

<a id="ref2"></a>[2] Khan, A., & Rasool, S. (2022). Game induced emotion analysis using electroencephalography. Computers in Biology and Medicine, 145, 105441.[[pdf]](https://www.sciencedirect.com/science/article/abs/pii/S0010482522002335?via%3Dihub)

<a id="ref3"></a>[3] Abdulrahman, A., Baykara, M., & Alakus, T. B. (2022). A novel approach for emotion recognition based on EEG signal using deep learning. Applied Sciences, 12(19), 10028.[[pdf]](https://www.mdpi.com/2076-3417/12/19/10028)

<a id="ref4"></a>[4] Alakus, T. B., & Turkoglu, I. J. E. L. (2020). Emotion recognition with deep learning using GAMEEMO data set. Electronics Letters, 56(25), 1364-1367.[[pdf]](https://ietresearch.onlinelibrary.wiley.com/doi/10.1049/el.2020.2460)

<a id="ref5"></a>[5] Rafal Chalupnik, Katarzyna Bialas, Zofia Majewska & Michal Kedziora.(2022).Using Simplified EEG-Based Brain Computer Interface and Decision Tree Classifier for Emotions Detection[[pdf]](https://link.springer.com/chapter/10.1007/978-3-030-99587-4_26)

<a id="ref6"></a>[6] Shashank Joshi, Falak Joshi.(2021).HUMAN EMOTION CLASSIFICATION BASED ON EEG SIGNALS USING RECURRENT NEURAL NETWORK AND KNN[[pdf]](https://arxiv.org/abs/2205.08419)

<a id="ref7"></a>[7] Manish Manohare, E. Rajasekar, Manoranjan Parida.(2023).Electroencephalography based classification of emotions associated with road traffic noise using Gradient boosting algorithm[[pdf]](https://www.sciencedirect.com/science/article/abs/pii/S0003682X23001044)

<a id="ref5"></a>[5] Suat Toraman and Ömer Osman Dursun.(2021).GameEmo-CapsNet: Emotion Recognition from Single-Channel EEG Signals Using the 1D Capsule Networks[[pdf]](https://www.researchgate.net/publication/357772057_GameEmo-CapsNet_Emotion_Recognition_from_Single-Channel_EEG_Signals_Using_the_1D_Capsule_Networks)

<a id="ref5"></a>[5] T. B. Alakus and I. Turkoglu.(2020).Emotion recognition with deep learningusing GAMEEMO data set[[pdf]](https://ietresearch.onlinelibrary.wiley.com/doi/epdf/10.1049/el.2020.2460)
