#!/usr/bin/env python
# coding: utf-8

# In[29]:


import tensorflow as tf
import numpy as np

test_graphs=np.loadtxt(open("../Tox21_AR/score_graphs.csv", "rb"), delimiter=",")
test_nodes=np.loadtxt(open("../Tox21_AR/score_nodes.csv", "rb"), delimiter=",",skiprows=1)


# In[30]:


tnodes=np.asarray([node[1] for node in test_nodes]).reshape((-1,132))


# In[31]:


def relu(X):
    return np.maximum(0,X)
def gcn_layer(A_hat, D_hat, X):
    out=[]
    for i in range(len(A_hat)):
        #tmp_1=np.matmul(iD_hat,A_hat[i])
        tmp_2=np.matmul(A_hat[i],X[i])
        out.append(tmp_2)
    return relu(out)


# In[32]:


len(test_graphs)/132


# In[33]:


#test
A = test_graphs.reshape(-1,132,132)
#print(A.shape)
I = np.eye(132).reshape((132,132)).astype(int)
A_hat = A + I
#print(A_hat)
D_hat = np.array(np.sum(A_hat, axis=0))[0]
#print(D_hat.shape)
D_hat = np.matrix(np.diag(D_hat))
#print(D_hat.shape)
X = tnodes.reshape((-1,132,1)).astype(int)
tp=np.ones(132)
iD_hat=np.where(D_hat!=0,tp/D_hat,0)
H_1 = gcn_layer(A_hat, D_hat, X)
H_2 = gcn_layer(A_hat, D_hat, H_1)
toutput = H_2.reshape(-1,132)


# In[39]:


tgraphs = test_graphs.reshape(-1, 1, 132, 132)

normedtout = (toutput - toutput.mean(axis = 0))
normedtout = np.where(np.abs(normedtout).max(axis=0)!=0,(normedtout / np.abs(normedtout).max(axis=0))*0.15,0)

tgcn_graphs = []
for i in range(len(tgraphs)):
    tgcn_graphs.append(tgraphs[i]+normedtout[i])
tgcn_graphs = np.asarray(tgcn_graphs)


images_nchw = tgcn_graphs  # input batch, tgcn_graphs||tgraphs
tout = images_nchw.transpose(0, 2, 3, 1)

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

checkpoint_path = "training_all/cp.ckpt"
model.load_weights(checkpoint_path)

result = model.predict(tout)


# In[40]:


with open("labels.txt","w+") as f:
    for i in range(len(result)):
        if result[i][0] >= 0.5:
            if i==len(result)-1:
                f.write("1")
            else:
                f.write("1\n")
        else:
            if i==len(result)-1:
                f.write("0")
            else:
                f.write("0\n")
    f.close()


# In[ ]:




