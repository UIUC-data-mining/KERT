% for PKDD paper
% function FromBLDA(pttfile)
% do ranking based on blda results pttopic file
%% input selection
% input path
inputpath = '../dblp/k100/';
% output path
outputpath = '../dblp/k100/';
% the name of term dictionary file
dictfile = [inputpath 'word_index.txt'];
% the name of the topic model result file
pttfile = [inputpath 'ptt.txt'];
% the name of the output file
outputfile = [outputpath 'phrase.kert'];
% the maximal length of phrases to mine
maxn = 4;
% the minimal suppport of phrases
minsup = 15;
% the broken phrase filtering condition
root.gamma = 0.5;
% the weight for phraseness, while the weight for purity is 1
root.wp = 1.0;
% the final maximal length of phrases you want to output
root.maxn = 3;
% the number of phrases you want to output for each topic
top = 10000;

% you don't need to change the following
savefile = [outputpath 'fromblda.mat'];
rootfile = [outputpath '_0.mat'];
prepare_news;
save(rootfile,'root');

%% mining, everything indexed from 1
load(rootfile);
ptt = load(pttfile);

[ngramdict,zfreq,np] = MinePattern(ptt,maxn,minsup);
save(savefile,'ngramdict','zfreq','np');
StorePTSeq(ptt,savefile);

%% ranking
load(rootfile);
load(savefile);
wp = root.wp;
frac = root.gamma;
maxn = root.maxn;
k = size(zfreq{1},2);

gg = RankNgram7(ngramdict(1:maxn),zfreq,np,wp,frac);
% full ranking function
ngramname = cell(1,k);
for i=1:k
    ngramname{i}=GetNgram(ngramdict,gg{i}(1:min(top,size(gg{i}(:,1))),:),...
        root.idterm,PT,pt);
end    
for i=1:k
% the following is for outputing the score of each phrase in each topic
    OutputNgram([root.prefix int2str(i) '.score'],gg{i},ngramdict);
end

%% output 
WriteName(outputfile,ngramname);    
% OutputPhrase4MI([root.prefix 'kert'],gg,ngramdict,zfreq,root.map);
