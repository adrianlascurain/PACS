function newBlockCounter = increaseCounter(counterBlock)
    %% Standard incrementing function m = 8
    counterBlock(end) = mod(counterBlock(end)+1,256);
    for i = length(counterBlock) : -1 : 2
        if counterBlock(i) ~= 0
            break
        end
        counterBlock(i-1) = mod(counterBlock(i-1)+1,256);
    end
    newBlockCounter = counterBlock;
end