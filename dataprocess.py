import pandas as pd
import os
import numpy as np

file_pth = './Subject_feature'
all_file_name = os.listdir(file_pth)
num = len(all_file_name)
df = pd.DataFrame()

for idx in range(num):
    if all_file_name[idx][7] == 'f' :
        #print(all_file_name[idx])
        data = pd.read_csv(os.path.join(file_pth, all_file_name[idx]))
        con = []
        
        for index, row in data.iterrows():
            
            for col in data.columns[1:]:  
                #print(col)
                con.append(f"{row['Channel']} {col}")
                #print(index)
            '''
            for col in data.columns[1:2]:  
                #print(col)
                con.append(f"{row['Channel']} {col}")
                #print(index)
            for col in data.columns[3:5]:  
                #print(col)
                con.append(f"{row['Channel']} {col}")
                #print(index)
            for col in data.columns[7:8]:  
                #print(col)
                con.append(f"{row['Channel']} {col}")
                #print(index)
            for col in data.columns[9:10]:  
                #print(col)
                con.append(f"{row['Channel']} {col}")
                #print(index)
            for col in data.columns[13:15]:  
                #print(col)
                con.append(f"{row['Channel']} {col}")
                #print(index)
            '''
            #if index == 7:
            #   break
        con.append('label')
        '''
        new_data = data.iloc[0:8, 1:2].values.flatten()
        new_data = np.append(new_data, data.iloc[0:8, 3:5].values.flatten())
        new_data = np.append(new_data, data.iloc[0:8, 7:8].values.flatten())
        new_data = np.append(new_data, data.iloc[0:8, 9:10].values.flatten())
        new_data = np.append(new_data, data.iloc[0:8, 13:15].values.flatten())
        '''
        new_data = data.iloc[:, 1:].values.flatten()
        new_data = list(new_data)+[all_file_name[idx][5]]
        #print(newrow)
        new_df = pd.DataFrame([new_data], columns=con)
        
        df = pd.concat([df, new_df])
        #print(df)
print("\nTransformed DataFrame:")
print(df)
df.to_csv('data_allfeatures_allchannel_filtered.csv')