# -*- coding: utf-8 -*-
"""
Created on Mon Dec 22 13:59:58 2014

@author: abrooks
"""
import nltk
import re 
import string
import pandas as pd

def removeStopWords(tokens):
    ''' removes the basic list of English stop words from a list of tokens'''
    tokens0 = []    
    masterStopList = nltk.corpus.stopwords.words('english')
    masterStopList.extend(['said', 'many', 'also', 'mr', 'get', 'dont', 'would', 
    'could', 'like', 'go', 'lot', 'make'])
    masterStopList.extend(list(string.ascii_lowercase))
    for t in tokens:
        if not t in masterStopList:
            tokens0.append(t)
    return tokens0
        
def removeTokensWithNumbers(tokens):
    ''' removes tokens that are numbers '''
    regexp = re.compile(r'[0-9]')
    tokens0=[]
    for t in tokens:
        if regexp.search(t) is None:
            tokens0.append(t)
    return tokens0
    
def stemMorphy(tokens):
    ''' simple light stemmer for tokens... nouns only'''
    tokens0=[]
    for t in tokens:
        tl = nltk.corpus.wordnet._morphy(t, nltk.corpus.wordnet.NOUN)
        if len(tl)==0: 
            tokens0.append(t)
        else:
            tokens0.append(tl[len(tl)-1])
    return tokens0

def printHeadlines(art, topic=0, limit=10):
    ''' basic way to print headlines for articles in a particular topic'''
    alim = 0
    for i in range(len(art)):
        if art[i]['topic1']==topic:
            alim+=1
            print(art[i]['headline'])
            print('')
        if alim>limit: break

def aggTopics(lda_corpus, num_topics):
    ''' calculates a vector of probabilities for each topic.  The probabilities are the 
    probability that a document belongs in that class.  Returned is a list of lists with length
    equal to the number of topics '''
    probs = [[] for j in range(num_topics)]
    for i in range(len(lda_corpus)):
        for t in range(len(lda_corpus[i])):
            topic = lda_corpus[i][t][0]     
            probs[topic].append(lda_corpus[i][t][1])
    return probs
    
def topTopicProb(tdf):
    ''' for the most likely topic for each document, grab the probability it belongs to 
    that topic and put it into a list.  Returned is a list of lists equal to # of topics'''
    tv = [[] for j in range(tdf.shape[1])]
    xmax = tdf.idxmax(1,).astype(int)
    for i in range(len(xmax)): tv[xmax[i]].append(tdf.loc[i, xmax[i]])
    return tv
    
def lda2df(lda_corpus):
    ''' this function converts the vectors of topic probabilities into a matrix. rows are documents. columns are topics.
    This is very slow in high dimensions -- needs speeding up'''    
    ts = [pd.DataFrame(lda_corpus[i]) for i in range(len(lda_corpus))]
    df = ts[0]
    for i in range(1,len(ts)): df = pd.merge(df, ts[i], left_on=0, right_on=0, how='outer')
    df.index= df[0]
    df.pop(0)
    df = df.fillna(0)
    df.columns = range(len(ts))
    df.sort_index(inplace=True)
    df = df.transpose()
    return df
    
def unlist(list, elem, subelem=None, keepMissing=True):
    ''' simple way to extract a particular feature from a list of lists with the same name 
    basically just helping me remember how to do list comprehensions'''
    if subelem==None: ret = [i[elem] if elem in i.keys() else None for i in list]
    else: ret = [i[elem][subelem] if subelem in i[elem].keys() else None for i in list]
    if keepMissing==False: ret = [i for i in ret if i != None]
    return ret

def getTopWords(ldamodel, t, topn=20):
    '''print top words for a given category'''
    tmp=[ldamodel.show_topic(t, topn)[i][1] for i in range(len(ldamodel.show_topic(t, topn)))]
    return tmp

def topWords2df(lda, num_words=10):
    ''' convert top words for each topic into a dataferame ''' 
    ret = [pd.DataFrame(lda.show_topic(i, num_words)) for i in range(lda.num_topics)]
    return ret
    
def wordProb2df(lda, artdict, word):
    df=pd.DataFrame(lda[artdict.doc2bow([word])])  
    df.columns = ['topic', 'prob']
    return df
    
    
def prettyWordLabels(lda, topn=3):
    '''prettify key words for each topic'''
    labels=[str([str(x) for x in getTopWords(lda,i,topn)]) for i in range(lda.num_topics)]
    labels=[re.sub('\[|\]|\'', '', i) for i in labels]
    return labels
    


## still working on this
#class topicsAgg:
#    ''' still working on this.  this may not be fruitful '''
#    def __init__(self,lda,corpus):
#        self.lda = lda
#        self.corpus = corpus
#    def thing(self): return self.corpus[1]
        
        
    

        