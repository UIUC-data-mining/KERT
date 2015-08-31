This is a github mirror of the link found from Illimine
<a href="http://illimine.cs.uiuc.edu/software/kert/">here</a>.

Data is provided in this github repository, only because it does not consume
too much space.

**** Illimine Copyright ****

University of Illinois at Urbana-Champaign, 2014

illimine.cs.illinois.edu


**** Additional Copyright ****

This package contains the source code and the dataset used in the following paper:

@inproceedings{conf/sdm/KERT14,
  author    = {Marina Danilevsky and Chi Wang and Nihit Desai and Xiang Ren and Jingyi Guo and Jiawei Han},
  title     = {Automatic Construction and Ranking of Topical Keyphrases on Collections of Short Documents},
  booktitle = {SDM},
  year      = {2014},
  ee        = {http://dx.doi.org/10.1137/1.9781611973440.46},
}


If you use any contents in this package, please cite the above paper as your reference.


**** Code explanation ****

(1). The input file is %1.txt under the folder %data. Every line is a string representing one document.

(2). Set up the parameters in flat_kert.bat

	data: the input folder;

	output: the output folder;

	code: the code folder;

	ntopic: number of topics;

	minsup: the minimum frequency for a phrase;

	gamma: the parameter for completness condition, default 0.5;

	options.wp: the weight for phraseness;

	options.maxn: the longest phrase length;

	options.top: the number of phrases output for each topic;

(3). Execute

	flat_kert.bat

	This version of code uses LDA as the topic model. If you want to try BLDA, please use blda.py instead of mallet LDA. See readme_blda.txt in the code folder.

(4). Output:

    %1.kert - %ntopic% lines, each containing top %options.top% phrases for one topic,
    separated by \t.


**** Data explanation ****

This package contains a subset of DBLP paper titles in 20 conferences.

word_index.txt - the dictionary of terms, indexed from 1
pt.txt - the terms in each paper title. Every line has two columns: paper id and term id. Both are indexed from 1

**** For More Questions ****

Please contact illimine.cs.illinois.edu or Chi Wang (chiwang1@illinois.edu)
