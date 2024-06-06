import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn import neighbors
from sklearn.model_selection import cross_val_score, KFold
from sklearn.metrics import confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt

#data = pd.read_csv('data_allfeatures_allchannel_raw.csv')
#data = pd.read_csv('data_allfeatures_Fchannel_raw.csv')
#data = pd.read_csv('data_hybridfeatures_allchannel_raw.csv')
data = pd.read_csv('data_hybridfeatures_Fchannel_raw.csv')
#data = pd.read_csv('data_allfeatures_allchannel_filtered.csv')
#data = pd.read_csv('data_allfeatures_Fchannel_filtered.csv')
#data = pd.read_csv('data_hybridfeatures_allchannel_filtered.csv')
#data = pd.read_csv('data_hybridfeatures_Fchannel_filtered.csv')
#data = pd.read_csv('data_allfeatures_allchannel_asr.csv')
#data = pd.read_csv('data_allfeatures_Fchannel_asr.csv')
#data = pd.read_csv('data_hybridfeatures_allchannel_asr.csv')
#data = pd.read_csv('data_hybridfeatures_Fchannel_asr.csv')

y = data['label']
X = data.drop('label', axis=1)

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
#print(X_scaled)

X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.4, random_state=42)

#print(y_train)
classifier = neighbors.KNeighborsClassifier()
classifier.fit(X_train, y_train)

y_pred = classifier.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print(f'Classification Accuracy: {accuracy:.2f}')
print('Classification Report:')
print(classification_report(y_test, y_pred))

k_fold = KFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(classifier, X, y, cv=k_fold, scoring='accuracy')
print("Mean Accuracy:", scores.mean())
print("Standard Deviation:", scores.std())

cm = confusion_matrix(y_test, y_pred)

labels = ['Bored', 'Calm', 'Horror', 'Funny']

plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=labels, yticklabels=labels)
plt.xlabel('Predicted Label')
plt.ylabel('True Label')
plt.title('Confusion Matrix')
plt.show()

''''''