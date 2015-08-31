#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Revised by Jingyi Guo
# Revised by Nihit Desai for ACL 2013 paper (date: Jan 22, '13)

import sys
import numpy
#import nltk

class BLDA:
    def __init__(self, K, alpha, beta, lamda, docs, V, smartinit=True):
        self.K = K #topic number
        self.alpha = alpha # parameter of topics prior
        self.beta = beta   # parameter of words prior
        self.lamda=lamda  #background prior
        self.docs = docs #documents
        self.V = V #size of vocabulary

        self.z_m_n = [] # topics of words of documents
        self.n_m_z = numpy.zeros((len(self.docs), K+1)) + alpha     # word count of each document and topic
        self.n_z_t = numpy.zeros((K+1, V)) + beta # word count of each topic and vocabulary
        self.n_z = numpy.zeros(K+1) + V * beta    # word count of each topic

        self.N = 0
        for m, doc in enumerate(docs):
            self.N += len(doc)
            z_n = []
            for t in doc:
                if smartinit:
                    p_z0=self.n_z_t[0, t]*lamda/self.n_z[0]
                    p_z1 = self.n_z_t[1:, t] * self.n_m_z[m,1:]*(1-lamda) / (self.n_z[1:]*(K*alpha+len(doc)-self.n_m_z[m,0]))
                    p_z=numpy.zeros(K+1)
                    p_z[0]=p_z0
                    p_z[1:]=p_z1#normalize p_z0 and p_z1
                    z = numpy.random.multinomial(1, p_z / p_z.sum()).argmax()
                else:
                    z = numpy.random.randint(0, K+1)
                z_n.append(z)
                self.n_m_z[m, z] += 1
                self.n_z_t[z, t] += 1
                self.n_z[z] += 1
            self.z_m_n.append(numpy.array(z_n))

    def inference(self):
        """learning once iteration"""
        for m, doc in enumerate(self.docs):
            z_n = self.z_m_n[m]# topics of words of documents
            n_m_z = self.n_m_z[m]# word count of each document and topic
            for n, t in enumerate(doc):
                # discount for n-th word t with topic z
                z = z_n[n]
                n_m_z[z] -= 1
                self.n_z_t[z, t] -= 1
                self.n_z[z] -= 1

                # sampling topic new_z for t
                #p_z = self.n_z_t[:, t] * n_m_z / self.n_z
                #new_z = numpy.random.multinomial(1, p_z / p_z.sum()).argmax()
                p_z0=self.n_z_t[0, t]*self.lamda/self.n_z[0]
                #The probability of a word coming from background is
                #(beta+N_{(.,t,B)}^{-(i,j)})*lamda
                #------------------------------
                #(V*beta+N_{(.,.B)}^{-(i,j)})
            	#N_{(i,t,z)}^{-(i,j)}=>the count of appearance that ith document has word type t assigned to topic z
                #without considering the ith document jth word.
                p_z1 = self.n_z_t[1:, t] * self.n_m_z[m,1:]*(1-self.lamda) / (self.n_z[1:]*(self.K*self.alpha+len(doc)-1-self.n_m_z[m,0]))
                #The probability of a word coming from non background topic z is
                #(beta+N_{(.,t,z)}^{-(i,j)})*(alpha+N_{(i,.,z)}^{-(i,j)})*(1-lamda)
                #-----------------------------------------------------------------
                #(V*beta+N_{(.,.,z)}^{-(i,j)})*(K*alpha+N_{(i,.,.)}^{-(i,j)})
                p_z=numpy.zeros(self.K+1)
                p_z[0]=p_z0
                p_z[1:]=p_z1#normalize p_z0 and p_z1
                new_z = numpy.random.multinomial(1, p_z / p_z.sum()).argmax()

                # set z the new topic and increment counters
                z_n[n] = new_z
                n_m_z[new_z] += 1
                self.n_z_t[new_z, t] += 1
                self.n_z[new_z] += 1

    def assign_final_topics(self):
         for m, doc in enumerate(self.docs):
            z_n = self.z_m_n[m]# topics of words of documents
            n_m_z = self.n_m_z[m]# word count of each document and topic
            for n, t in enumerate(doc):
                # discount for n-th word t with topic z
                z = z_n[n]
                n_m_z[z] -= 1
                self.n_z_t[z, t] -= 1
                self.n_z[z] -= 1

                # sampling topic new_z for t
                #p_z = self.n_z_t[:, t] * n_m_z / self.n_z
                #new_z = numpy.random.multinomial(1, p_z / p_z.sum()).argmax()
                p_z0=self.n_z_t[0, t]*self.lamda/self.n_z[0]
                #The probability of a word coming from background is
                #(beta+N_{(.,t,B)}^{-(i,j)})*lamda
                #------------------------------
                #(V*beta+N_{(.,.B)}^{-(i,j)})
            	#N_{(i,t,z)}^{-(i,j)}=>the count of appearance that ith document has word type t assigned to topic z
                #without considering the ith document jth word.
                p_z1 = self.n_z_t[1:, t] * self.n_m_z[m,1:]*(1-self.lamda) / (self.n_z[1:]*(self.K*self.alpha+len(doc)-1-self.n_m_z[m,0]))
                #The probability of a word coming from non background topic z is
                #(beta+N_{(.,t,z)}^{-(i,j)})*(alpha+N_{(i,.,z)}^{-(i,j)})*(1-lamda)
                #-----------------------------------------------------------------
                #(V*beta+N_{(.,.,z)}^{-(i,j)})*(K*alpha+N_{(i,.,.)}^{-(i,j)})
                p_z=numpy.zeros(self.K+1)
                p_z[0]=p_z0
                p_z[1:]=p_z1#normalize p_z0 and p_z1
                #new_z = numpy.random.multinomial(1, p_z / p_z.sum()).argmax()
                final_z = p_z.argmax()
                print "%d\t%d\t%d\n" % (m,t,final_z)

                # set z the new topic and increment counters
                z_n[n] = final_z
                n_m_z[final_z] += 1
                self.n_z_t[final_z, t] += 1
                self.n_z[final_z] += 1


    def worddist(self):
        """get topic-word distribution"""
        #This is phi distribution
        return self.n_z_t / self.n_z[:, numpy.newaxis]

    def perplexity(self, docs=None):
        if docs == None: docs = self.docs
        phi = self.worddist()
        log_per = 0
        N = 0
        Kalpha = self.K * self.alpha
        for m, doc in enumerate(docs):
            theta = self.n_m_z[m][1:] / (len(self.docs[m])-self.n_m_z[m][0]+ Kalpha)
            for w in doc:
                log_per -= numpy.log(numpy.inner(phi[1:,w], theta)*(1-self.lamda)+phi[0,w]*self.lamda)
                #compute perplexity
            N += len(doc)
        return numpy.exp(log_per / N)

def blda_learning(lda, iteration):
    pre_perp = lda.perplexity()
    #print "initial perplexity=%f" % pre_perp
    for i in range(iteration):
        lda.inference()
        perp = lda.perplexity()
        #print "-%d p=%f" % (i + 1, perp)
        if pre_perp:
            if pre_perp < perp:
                pre_perp = None
            else:
                pre_perp = perp
    #insert final output here - pid tid topic_assignment
    lda.assign_final_topics()

def main():
    import optparse
    import vocabulary
    parser = optparse.OptionParser()
    parser.add_option("-f", dest="filename", help="corpus filename")
    parser.add_option("--alpha", dest="alpha", type="float", help="parameter alpha", default=0.5)
    parser.add_option("--beta", dest="beta", type="float", help="parameter beta", default=0.5)
    parser.add_option("--lamda", dest="lamda", type="float", help="parameter lamda", default=0.5)
    parser.add_option("-k", dest="K", type="int", help="number of topics", default=20)
    parser.add_option("-i", dest="iteration", type="int", help="iteration count", default=100)
    parser.add_option("-s", dest="smartinit", action="store_true", help="smart initialize of parameters", default=False)
    parser.add_option("--stopwords", dest="stopwords", help="exclude stop words", action="store_true", default=False)
    parser.add_option("--seed", dest="seed", type="int", help="random seed")
    parser.add_option("--df", dest="df", type="int", help="threshold of document freaquency to cut words", default=0)
    (options, args) = parser.parse_args()
    if not (options.filename): parser.error("need corpus filename(-f) or corpus range(-c)")
    if options.filename:
        (pids,tids) = vocabulary.load_file(options.filename)
    if options.seed != None:
        numpy.random.seed(options.seed)
    #voca is the object which stores the data structures needed by LDA    
    voca = vocabulary.Vocabulary(options.stopwords)
    docs = voca.PT_to_idlist(pids, tids)
    #print docs
    size_of_vocab = max(tids) + 1;
    lda = BLDA(options.K, options.alpha, options.beta, options.lamda, docs, size_of_vocab, options.smartinit)
    #print "corpus=%d, words=%d, K=%d, a=%f, b=%f" % (len(corpus), len(voca.vocas), options.K, options.alpha, options.beta)
    blda_learning(lda, options.iteration)

if __name__ == "__main__":
    main()
