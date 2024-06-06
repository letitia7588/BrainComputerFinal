import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

data1 = pd.read_csv('./Subject_feature/S01_G1_asr_features.csv')
data2 = pd.read_csv('./Subject_feature/S01_G2_asr_features.csv')
data3 = pd.read_csv('./Subject_feature/S01_G3_asr_features.csv')
data4 = pd.read_csv('./Subject_feature/S01_G4_asr_features.csv')
p2p1 = data1['Mean']
Gamma1 = data1['Beta_Power']
p2p2 = data2['Mean']
Gamma2 = data2['Beta_Power']
p2p3 = data3['Mean']
Gamma3 = data3['Beta_Power']
p2p4 = data4['Mean']
Gamma4 = data4['Beta_Power']

#plt.figure(figsize=(10, 8))
#sns.heatmap(corr, annot=True, cmap='coolwarm', linewidths=0.5)
#plt.show()
# 绘制散布图
plt.figure(figsize=(8, 6))
plt.scatter(p2p1, Gamma1, c='blue', label = 'Boring')  # 'c' 指定颜色，'label' 指定标签
plt.scatter(p2p2, Gamma2, c='green', label = 'Calm')  # 'c' 指定颜色，'label' 指定标签
plt.scatter(p2p3, Gamma3, c='red', label = 'Horror')  # 'c' 指定颜色，'label' 指定标签
plt.scatter(p2p4, Gamma4, c='yellow', label = 'Funny')  # 'c' 指定颜色，'label' 指定标签
#plt.title('Scatter Plot of Peak_to_Peak_Time vs Gamma_Power')
plt.xlabel('Mean')
plt.ylabel('Gamma_Power')
plt.legend()  # 显示图例

# 显示图形
plt.show()