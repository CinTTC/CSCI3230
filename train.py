#!/usr/bin/env python
# coding: utf-8

# In[4]:


import tensorflow as tf
import csv
import numpy as np
import os

def readfile(file_path):
    with open(file_path) as f:
        t_label=[]
        tmp=[]
        label= csv.reader(f,delimiter=',')
        for row in label:
            tmp=[]
            for col in row:
                col=col.strip()
                tmp.append(col)
            t_label.append(tmp)
        return t_label
    
file_path = '/Users/t6052/Desktop/DNN Project/train_data/train_graph_size.csv'
file_path1 = '/Users/t6052/Desktop/DNN Project/train_data/train_graphs.csv'
file_path2 = '/Users/t6052/Desktop/DNN Project/train_data/train_labels.csv'
file_path3 = '/Users/t6052/Desktop/DNN Project/train_data/train_nodes.csv'
train_graph_size=readfile(file_path) #no need first line
train_graphs=readfile(file_path1)
train_labels=readfile(file_path2)
train_nodes=readfile(file_path3)

train_nodes=train_nodes[1:]
train_graph_size=train_graph_size[1:]
train_labels=train_labels[1:]
train_graph_size = [size[1] for size in train_graph_size]

nodes=np.asarray([node[1] for node in train_nodes]).reshape((-1,132))

def pad(graph, size):
    graphs = []
    start, end = 0,0
    if int(len(graph)/132) == len(size): 
        return np.asarray(graph).astype(float)
    for i in range(len(size)):
        end += size[i]
        tmp = np.asarray(graph[start:end])
        tmp = np.pad(tmp,((0,132-size[i]),(0,132-size[i])),'constant', constant_values=0)
        start += size[i]
        graphs.append(tmp)
    return np.asarray(graphs).astype(float)

graphs = pad(train_graphs, train_graph_size).astype(float)

def relu(X):
    return np.maximum(0,X)
def gcn_layer(A_hat, D_hat, X):
    out=[]
    for i in range(len(A_hat)):
        #tmp_1=np.matmul(iD_hat,A_hat[i])
        tmp_2=np.matmul(A_hat[i],X[i])
        out.append(tmp_2)
    return relu(out)

#train
A = graphs.reshape((int(len(graphs)/132),132,132))
print(A.shape)
I = np.eye(132).reshape((132,132)).astype(int)
A_hat = A + I
#print(A_hat)
D_hat = np.array(np.sum(A_hat, axis=0))[0]
print(D_hat.shape)
D_hat = np.matrix(np.diag(D_hat))
print(D_hat.shape)
tp=np.ones(132)
iD_hat=np.where(D_hat!=0,tp/D_hat,0)
X = nodes.reshape((-1,132,1)).astype(int)
H_1 = gcn_layer(A_hat, iD_hat, X)
H_2 = gcn_layer(A_hat, iD_hat, H_1)
output = H_2.reshape(-1,132)

normedout = (output - output.mean(axis = 0))
normedout = np.where(np.abs(normedout).max(axis=0)!=0,(normedout / np.abs(normedout).max(axis=0))*0.2,0)

graphs = np.reshape(graphs, (-1, 1, 132, 132))

gcn_graphs = []
for i in range(len(normedout)):
    gcn_graphs.append(graphs[i]+normedout[i])
gcn_graphs = np.asarray(gcn_graphs)

def preprocess_l(given_labels):
    labels = []
    for i in range(len(given_labels)):
        labels.append([int(given_labels[i][1])])
    return labels

labels = preprocess_l(train_labels)

def data_increase(data, label):
    new_data, new_label = [], []
    for i in range(len(label)):
        tmp = int(5)#label[i]
        if abs(1-label[i][0]) < 0.1:
            new_label.append(tmp)
            new_data.append(data[i])
            new_label.append(tmp)
            new_data.append(data[i])
            new_label.append(tmp)
            new_data.append(data[i])
            new_label.append(tmp)
            new_data.append(data[i]) #can duplicate more
        new_label.append(int(0))#tmp)
        new_data.append(data[i])
    new_data=np.asarray(new_data)
    return new_data, new_label

new_graphs, new_labels = data_increase(gcn_graphs,labels) #gcn->(gcn_graphs, labels), fc->(graphs,labels)


# In[11]:



images_nchw = new_graphs  # input batch
out = images_nchw.transpose(0, 2, 3, 1)

input_shape = (132,132,1)
model = tf.keras.models.Sequential([
  #tf.keras.layers.Conv2D(32, kernel_size=(3,3), strides=1, activation='relu', input_shape=input_shape, data_format='channels_last'),
  #tf.keras.layers.BatchNormalization(input_shape=input_shape),
  #tf.keras.layers.Conv2D(15, kernel_size=(3,3), strides=1, activation='relu', data_format='channels_last'),
  #tf.keras.layers.BatchNormalization(),
  #tf.keras.layers.MaxPooling2D(pool_size=(2, 2)),
  tf.keras.layers.Flatten(input_shape=input_shape),
  tf.keras.layers.Dense(900, activation='relu'), 
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(300, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(60, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(1, activation=tf.nn.sigmoid)
])

model.compile(optimizer='adam',
              loss='binary_crossentropy',
              metrics=['accuracy'])
checkpoint_path = "training_1_gcn/cp.ckpt"
checkpoint_dir = os.path.dirname(checkpoint_path)

cp_callback = tf.keras.callbacks.ModelCheckpoint(filepath=checkpoint_path,
                                                  save_weights_only=True,
                                                  verbose=1)
model.fit(out, new_labels, epochs=10,shuffle=True), callbacks=[cp_callback])


# In[ ]:




