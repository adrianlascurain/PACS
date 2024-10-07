function [decryptedCell,initCounters,invalidKeyFlag] = decipherCellArray(data,key,initCounter)
    invalidKeyFlag = false;

    %% Preallocate a cell array for ciphered data and for counters
    initCounters = cell(1,length(data));
    decryptedCell = cell(1,length(data));
    
    initCounters{1} = initCounter;
    
    %% Cipher data and save counters
    for i = 1 : length(data)
        dataT = data{i};
        [r,~] = size(dataT);
        if r>1
            dataT = dataT';
        end
        [decipherText,IC,LC] = AES_CTR_CC(dataT,key,initCounter);
        initCounter = LC;
        initCounters{i} = IC;
        try
            decryptedCell{i} = getArrayFromByteStream(uint8(decipherText));
        catch
            invalidKeyFlag = true;
        end
    end
end