% Author: Chi Wang (chiwang1@illinois.edu)
% do ranking based on lda results pttopic file and mined patterns
function KERT(datapath, output, options)
%% input selection
% the name of term dictionary file
dictfile = [datapath 'word_index.txt'];
% the name of the topic model result file
pttfile = [datapath 'ptt.txt'];
% the name of the pattern file
patternfile = [datapath 'ngram.'];
% the broken phrase filtering condition (done externally)
gamma = options.gamma;
% the weight for phraseness, while the weight for purity is 1
wp = options.wp;
% the final maximal length of phrases you want to output
maxn = options.maxn;
% the number of phrases you want to output for each topic
top = options.top;

% you don't need to change the following
savefile = [datapath 'kert_fromlda.mat'];
idterm = ReadName(dictfile);

%% mining, everything indexed from 1
ptt = load(pttfile);
[ngramdict,zfreq,np] = LoadAllPhrases(patternfile);
% totalp = max(ptt(:,1));
save(savefile,'ngramdict','zfreq','np');
StorePTSeq(ptt,savefile);

%% ranking
load(savefile);
tic;
k = size(zfreq{1},2);
% gg = RankNgram_loosebg(ngramdict(1:maxn),zfreq,np,wp,gamma,totalp);
gg = RankNgram7(ngramdict(1:maxn),zfreq,np,wp,gamma);
toc;
% full ranking function
ngramname = cell(1,k);
for i=1:k
    ngramname{i}=GetNgram(ngramdict,gg{i}(1:min(top,size(gg{i}(:,1))),:),...
        idterm,PT,pt);
% the following is for outputing the score of each phrase in each topic
% OutputNgram([root.prefix int2str(i) '.score'],gg{i},ngramdict,root.map);
end    
% output 
outputfile = [datapath output '.kert'];
WriteName(outputfile,ngramname);    
% OutputPhrase4MI([root.prefix 'kert'],gg,ngramdict,zfreq,root.map);
toc;