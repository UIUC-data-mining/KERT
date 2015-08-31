Instructions of BLDA

1. Run blda.py, assuming blda.py, vocabular.py and PT.txt in the same folder.

python ./Blda.py -f ../data/pt.txt --stopwords --alpha 1 --beta 0.07 --lamda 0.1 -k 5 -i 1000 -s > ptt.txt

parameters:

-f inputfile
    inputfile should be a PT network. Every line has two numbers paper id and term id. 
    Stopwords are already removed.
    
--alpha alpha
    alpha is the dirichlet prior for document-topic mixture
    
--beta beta
    beta is the dirichlet prior for topic-word mixture
    
--lam da lambda
    lambda is the proportion of background topic
    
-k number of topics

-i number of gibbs sampling iterations

> output file name


    

 
