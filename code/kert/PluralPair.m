function nameid = PluralPair(idterm)
% find plural form and single form
l = length(idterm{2});
nameid = containers.Map('KeyType','char','ValueType',int32);
pp = containers.Map('KeyType','int32','ValueType','int32');
% from plural to single
for i=1:l
    if length(idterm{2}{i})<1
         i
        continue;
    end
    nameid(idterm{2}{i}) = i;
end
for i=1:l
    if idterm{2}{i}(end)=='s' && length(idterm{2}{i})>1
        t1 = idterm{2}{i}(1:end-1);
        if isKey(nameid,t1)
            pp(i) = nameid(t1);
        end            
        % slow
%         l1 = length(t1);
%         for j=1:l
%             t2 = idterm{2}{j};
%             if length(t2)==l1 && strcmp(t2,t1)
%                 pp = [pp; i,j];
%                 break;
%             end
%         end
    end
end