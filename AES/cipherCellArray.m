function [cipheredCell,initCounters,LC] = cipherCellArray(data,key,initCounter)    
    %% Preallocate a cell array for ciphered data and for counters
    initCounters = cell(1,length(data));
    cipheredCell = cell(1,length(data));
    
    initCounters{1} = initCounter;
    
    %% Get all bytes from each field of cell array
    for i = 1 : length(data)
        data{i} = getByteStreamFromArray(data{i});
    end
    
    %% Cipher data and save counters
    for i = 1 : length(data)
        [cipherText,IC,LC] = AES_CTR_CC(data{i},key,initCounter);
        initCounter = uint8(LC);
        initCounters{i} = uint8(IC);
        cipheredCell(i) = {uint8(cipherText)};
    end
end