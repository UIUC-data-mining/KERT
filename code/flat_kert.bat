::te@echo off
@set data=E:\kert\data
@set output=%data%\%1
@set code=E:\kert\code
@set topic-state=topic-state
@set ntopic=%2
set minsup=5
set gamma=0.5

mkdir %output%
call mallet import-file --input %data%\%1.txt --output %output%\corpus.mallet --keep-sequence --remove-stopwords

call mallet train-topics --input %output%\corpus.mallet --num-topics %ntopic% --optimize-interval 10 --output-state %output%\%topic-state%.gz --output-topic-keys %output%\tutorl_keys.txt --output-doc-topics %output%\tutorial_compostion.txt 
"c:\Program Files\7-Zip\"7z e %output%\%topic-state%.gz
move %topic-state% %output%

cd %code%\
post_malletlda.py kert %output%\%topic-state% %output%\ptt.txt %output%\word_index.txt
post_malletlda.py tt %output%\%topic-state% %output%\word-assignments.dat %output%\vocab.dat %output%\corpus.txt

cd kert
echo kert pattern mine
java -jar PatternMine.jar  %output%\ %minsup% %gamma% 
echo kert ranking
call matlab -nojvm -nodisplay -nosplash -r "options.gamma=%gamma%;options.wp=1.0;options.maxn=4;options.top=1000;KERT('%output%\', '%1', options);exit" 

cd %code%