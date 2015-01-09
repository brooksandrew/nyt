# -*- coding: utf-8 -*-
"""
Created on Mon Dec 29 14:38:07 2014

@author: abrooks
"""


import os
import nltk as nltk
import string
import re
import numpy as np
import operator
import pandas as pd
from ggplot import *
import pickle
import datetime
os.chdir('/Users/abrooks/Documents/github/nyt')
from helpers import *
import random
from sklearn import tree

## retrieving results
art_file = open('articles_31234.p', 'rb')
artFull = pickle.load(art_file)

## randomly pick a sample from art
indices = random.sample(range(len((artFull))), 2000)
art = [artFull[i] for i in sorted(indices)]
#art = artFull

## CARRY OVER DATA PROCESSING
for i in range(len(art)): 
    art[i]['date_full'] = datetime.datetime.strptime(art[i]['pub_date'][0:10], '%Y-%m-%d')
    art[i]['date'] = datetime.date(art[i]['date_full'].year, art[i]['date_full'].month, art[i]['date_full'].day)


#########################################
## Non Topic Modeling analysis ##########
#########################################
df = pd.DataFrame(art)
xt = pd.crosstab(df['date'], df['type_of_material'])
xt['date'] = xt.index

ggplot(aes(x='date', y='News'), data=xt) + geom_line()

xtm = pd.melt(xt, id_vars=['date'])
ggplot(xtm, aes(x='date', y='value', color='type_of_material')) + geom_line()

## contingency table plots
tc = pd.DataFrame(df['type_of_material'].value_counts())
tc['type_of_material'] = tc.index
tc.columns.values[0]='value'
ggplot(aes(x='type_of_material', y='value'), data=tc[0:10]) + geom_bar(stat='identity')

tc = pd.DataFrame(df['document_type'].value_counts())
tc['document_type'] = tc.index
tc.columns.values[0]='value'
ggplot(aes(x='document_type', y='value'), data=tc[0:10]) + geom_bar(stat='identity')

tc = pd.DataFrame(df['section_name'].value_counts())
tc['section_name'] = tc.index
tc.columns.values[0]='value'
ggplot(aes(x='section_name', y='value'), data=tc[0:10]) + geom_bar(stat='identity')

tc['cumsum']=tc['value'].cumsum()
ggplot(aes(x='section_name', y='cumsum'), data=tc) + geom_bar(stat='identity')

#########################################
## LDA Topic Modeling ###################
#########################################
bds = [elem['text'] for elem in art]

import gensim

artdict = gensim.corpora.Dictionary(bds)
corpus = [artdict.doc2bow(text) for text in bds]

lda = gensim.models.ldamodel.LdaModel(corpus=corpus, id2word=artdict, num_topics=40, chunksize=200) ## online LDA

## inspecting topics by keywords visually
for i in range(lda.num_topics): print(i); getTopWords(lda, i)
    
## investigating strength of topics
ac = list(lda[corpus]) ## get probabilities that each document belongs to each topic.  some stochasticity here.
aa = aggTopics(ac, num_topics=lda.num_topics)
for i in range(len(aa)): print([i, len(aa[i]), np.median(aa[i])])

## Create dataframe of topic probabilities 
tdf = lda2df(ac)
for i in range(lda.num_topics): 
    ggplot(aes(x=i), data=tdf) + geom_histogram() + ggtitle('Topic' + str(i) + ':' + str([str(x) for x in getTopWords(lda,i,5)]))

## look at distribution of topic probabilities for winners of each topic
aat = topTopicProb(tdf)
aatdf = [pd.DataFrame(aat[i]) for i in range(len(aat))]
for i in range(lda.num_topics):
        ggplot(aes(x=0), data=aatdf[i]) + geom_histogram() +xlim(0,1) +\
        ggtitle('Topic' + str(i) + ':' + str([str(x) for x in getTopWords(lda,i,10)]))

winnersdf = pd.DataFrame([len(i) for i in aat])
winnersdf['topic1'] = winnersdf.index
winnersdf['topic1_w'] =  prettyWordLabels(lda,2)
ggplot(aes(x='topic1_w', y=0), data=winnersdf) + geom_bar(stat='identity') + xlab('topics') + ylab('count of articles')

## analyzing words for each topic
wdf = topWords2df(lda, 100)
for i in range(lda.num_topics):
    ggplot(aes(x=1, y=0), data=wdf[i][0:10]) + geom_bar(stat='identity') + xlab('Topic: ' + str(i)) + ylab('Probability')

## Plotting word probability distribution over topics
tmp = wordProb2df(lda, artdict, 'lamp')
ggplot(aes(x='topic', y='prob'), data=tmp) + geom_bar(stat='identity')


## adding topic data to original data
for i in range(len(corpus)):
    art[i]['topics'] = sorted(lda[corpus[i]], key=operator.itemgetter(1))
    art[i]['topics'].reverse()
    art[i]['topic1'] = art[i]['topics'][0][0]
    if i % 1000==0: print i, 'documents assigned topics'  

printHeadlines(art, 19, 10)
lda.show_topics()

## plotting time series of topics
df = pd.DataFrame(art)
xt = pd.crosstab(df['date'], df['topic1'])
xt['date'] = xt.index
xtm = pd.melt(xt, id_vars=['date'])
ggplot(xtm.loc[xtm.topic1<5], aes(x='date', y='value', color='topic1')) + geom_line()


#####################################################
## CLUSTERING USING TOPIC PROBABILITIES #############
#####################################################

## assigning strongest topic to tdf as a column
tdf2 = pd.DataFrame(np.repeat(None, tdf.shape[0]), columns=['topic1'])
for i in range(tdf.shape[0]): tdf2['topic1'][i] = tdf.loc[i,:].argmax()

## training decision tree
clf = tree.DecisionTreeClassifier()
clf.fit(tdf, tdf2['topic1'])

## KMEANS
from sklearn.cluster import KMeans, MiniBatchKMeans
from sklearn import metrics

km = KMeans(n_clusters=15, init='k-means++', n_init=10)
km.fit(tdf)
tdf2['km'] = km.labels_
xt=pd.crosstab(tdf2['km'], tdf2['topic1'])
print(xt)

print "Homogeneity: %0.3f" % metrics.homogeneity_score(tdf2['topic1'], km.labels_)
print "Completeness: %0.3f" % metrics.completeness_score(tdf2['topic1'], km.labels_)
print "V-measure: %0.3f" % metrics.v_measure_score(tdf2['topic1'], km.labels_)
print "Adjusted Rand-Index: %.3f" % metrics.adjusted_rand_score(tdf2['topic1'], km.labels_)

## hierarchical
from scipy.spatial.distance import pdist, squareform
from scipy.cluster.hierarchy import linkage, dendrogram
import matplotlib.pyplot as plt

data_dist = pdist(tdf.transpose()) # computing the distance
data_link = linkage(data_dist, method='complete', metric='euclidean') # computing the linkage

dendrogram(data_link, labels=tdf.columns) ## plotting

dendrogram(data_link, labels=prettyWordLabels(lda, 4))
plt.xlabel('Samples')
plt.ylabel('Distance')
plt.suptitle('Samples clustering', fontweight='bold', fontsize=14)

##########################################
## Visualization #########################
##########################################
import tethne.networks as nt

##########################################
## SUB LDA subtopic modeling #############
##########################################

t2 = [i['text'] for i in art if i['topic1']==20]
artdict2 = gensim.corpora.Dictionary(t2)
corpus2 = [artdict2.doc2bow(text) for text in t2]
lda2 = gensim.models.ldamodel.LdaModel(corpus=corpus2, id2word=artdict2, num_topics=3, chunksize=1) ## online LDA

for i in range(lda2.num_topics): 
    print(i)    
    getTopWords(lda2, i)


##########################################
## assessing how well topics fit data 
##########################################
df = pd.DataFrame(art)
xt = pd.crosstab(df['section_name'], df['topic1'])
