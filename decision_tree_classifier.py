import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn import tree

#data = pd.read_csv('data_allfeatures_allchannel_raw.csv')
#data = pd.read_csv('data_allfeatures_Fchannel_raw.csv')
#data = pd.read_csv('data_hybridfeatures_allchannel_raw.csv')
#data = pd.read_csv('data_hybridfeatures_Fchannel_raw.csv')
#data = pd.read_csv('data_allfeatures_allchannel_filtered.csv')
#data = pd.read_csv('data_allfeatures_Fchannel_filtered.csv')
#data = pd.read_csv('data_hybridfeatures_allchannel_filtered.csv')
#data = pd.read_csv('data_hybridfeatures_Fchannel_filtered.csv')
#data = pd.read_csv('data_allfeatures_allchannel_asr.csv')
#data = pd.read_csv('data_allfeatures_Fchannel_asr.csv')
#data = pd.read_csv('data_hybridfeatures_allchannel_asr.csv')
data = pd.read_csv('data_hybridfeatures_Fchannel_asr.csv')

y = data['label']
X = data.drop('label', axis=1)

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
#print(X_scaled)

X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.4, random_state=42)

#print(y_train)
classifier = tree.DecisionTreeClassifier()
classifier.fit(X_train, y_train)

y_pred = classifier.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print(f'Classification Accuracy: {accuracy:.2f}')
print('Classification Report:')
print(classification_report(y_test, y_pred))
''''''