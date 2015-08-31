function OutputPhrase4MI(filename,gg,ngramdict,zfreq,map)
% write the ngram (ids), topical frequency, and top ranked ids into a file
% for Mutual Information evaluation
% gg - first column is n, followed by the id in ngramdict{n}; last column
%   is the ranking score; 4th column - foreground prob; 6th - background
if iscell(ngramdict)
    f = fopen([filename '.dict'], 'w');
    countp = zeros(length(ngramdict),1); % the count for ngrams for each n
    for n=1:length(ngramdict)
        countp(n) = size(ngramdict{n},1);
        for i=1:countp(n)
    %         if gg(i,4)<=gg(i,6)
    %             break;
    %         end
    %         n = gg(i,1);
    %         seq = map(ngramdict{n}(gg(i,2),1:n));
            seq = map(ngramdict{n}(i,1:n));
            fprintf(f,'%d',n);
            for j=1:n
                fprintf(f,' %d',seq(j));
            end
            fprintf(f,'\n');
        %     fprintf(f,'%f\n',gg(i,end));
        end
        if n>1
            countp(n) = countp(n-1) + countp(n);
        end
    end
    countp(2:n) = countp(1:n-1);
    countp(1) = 0;
    fclose(f);
    f = fopen([filename '.freq'],'w');
    for n=1:length(zfreq)
        for i=1:size(zfreq{n},1)
            seq = full(zfreq{n}(i,:));
            k = size(zfreq{n},2);
            for j=1:k
                fprintf(f,'%f ',seq(j));
            end
            fprintf(f,'\n');
        end
    end
    fclose(f);
    f= fopen([filename '.top'],'w');
    topk = 1000;
    for z=1:k
        top = min(topk,size(gg{z},1));
        seq = countp(gg{z}(1:top,1))+gg{z}(1:top,2);
        for j=1:length(seq)
            fprintf(f,'%d ',seq(j));
        end
        fprintf(f,'\n');
    end
    fclose(f);
else
    f = fopen(filename, 'w');
    countp = length(ngramdict); % the count for ngrams for each n
    for i=1:countp
        seq = ngramdict(i);
        if ischar(seq)
            if seq(1)=='['
                seq = sscanf(seq(2:end-1),'%d');
            else
                seq = sscanf(seq,'%d');
            end
        end
%         [i seq]
        n = length(seq);
        fprintf(f,'%d',n);
        for j=1:n
            fprintf(f,' %d',seq(j));
        end
        fprintf(f,'\n');
    end
    fclose(f);
    f = fopen([filename '.freq'],'w');
    k = size(zfreq,2);
    for i=1:countp
        seq = zfreq(i,:);
        for j=1:k
            fprintf(f,'%f ',seq(j));
        end
        fprintf(f,'\n');
    end
    fclose(f);
    f= fopen([filename '.top'],'w');
    for z=1:k
        seq = gg(z,:);
        for j=1:length(seq)
            fprintf(f,'%d ',seq(j));
        end
        fprintf(f,'\n');
    end
    fclose(f);    
end

