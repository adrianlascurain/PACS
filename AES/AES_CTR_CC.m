function [CipherText,initCounter,lastCounter] = AES_CTR_CC(PlainText,Key,Counter)
% Advanced encryption standard with customized initial counter
%   This function ciphers the provided data using counter mode AES . CC
%   goes for custom counter.
    arguments
        PlainText {mustBeNonempty}
        Key {mustBeNonempty}
        Counter(1,16) {mustBeNonempty,mustBeInteger...
            ,mustBeGreaterThanOrEqual(Counter,0),mustBeLessThanOrEqual(Counter,255)}
    end
    
    initCounter = Counter;

    % Obtaining length of plain text
    LenOfPlainText = length(PlainText);
    
    % Creating the block counter (16 bytes can be stored in one block)
    NumberOfBlocks = ceil(LenOfPlainText/16);

    % Is the plain text packable in 16-byte blocks?
    Remainder = mod(LenOfPlainText,16);
    
    if Remainder == 0 % It is packable in 16-byte blocks
        %% Running the AES-CTR for all the blocks
        
        % Pre allocating cipher text (filled with zeros) in an array to enhance performance
        CipherText = zeros(4,4,NumberOfBlocks);
    
        % Reshaping the plain text into a 4-by-4-by-x matrix
        PlainText = double(reshape(PlainText,4,4,[]));
    
        for i=1:NumberOfBlocks

            % Encrypting the result of XOR between counter (FormattedCounter) 
            % and the initialization vector (IV) 
            EncryptedCounter = AES_encrypt(Counter,Key);
            Counter = increaseCounter(Counter);
    
            % Xoring the encrypted counter with a block of the plain text
            CipherText(:,:,i) = bitxor(EncryptedCounter,PlainText(:,:,i));        
        end
        CipherText = reshape(CipherText,1,[]);
    else % It is not packable in 16-byte blocks
        %% Running the AES-CTR just for the available bytes (1 to 15)
    
        % Calculating the number of necessary blocks
        NecessaryBlocks = floor(LenOfPlainText/16);
    
        % Is the number of blocks equal to 0?
        if NecessaryBlocks == 0 % The lenght of plain text is less than 16 bytes so not even a block is needed
    
            % Encrypting the result of XOR between counter (FormattedCounter) 
            % and the initialization vector (IV) 
            EncryptedCounter = AES_encrypt(Counter,Key);
            Counter = increaseCounter(Counter);
    
            % Xoring the encrypted counter with the available bytes of the plain text
            CipherText = bitxor(EncryptedCounter(end-Remainder+1:end),...
                double(PlainText(1:LenOfPlainText)));
    
        else % The length of plain text is greater than 16 bytes but is not a multiple of 16 (32,48,64,...)
            %% Running the AES-CTR for all the blocks except the last one
    
            % Calculating the number of necessary block
            NecessaryBlocks = floor(LenOfPlainText/16);
    
            % Pre allocating cipher text (filled with zeros) in an array to enhance performance
            CipherText = zeros(4,4,NecessaryBlocks);
        
            % Reshaping the plain text into a 4-by-4-by-x matrix
            AllPlainText = double(reshape(PlainText(1:NecessaryBlocks*16),4,4,[]));
            LastPlainText = double(PlainText(end-Remainder+1:end));
    
            %% AES-CTR until the penultimate block
            for i=1:NecessaryBlocks
                
                % Encrypting the result of XOR between counter (FormattedCounter) 
                % and the initialization vector (IV) 
                EncryptedCounter = AES_encrypt(Counter,Key);
                Counter = increaseCounter(Counter);
        
                % Xoring the encrypted counter with a block of the plain text
                CipherText(:,:,i) = bitxor(EncryptedCounter,AllPlainText(:,:,i));
            end       
            %% AES-CTR for the last block

    
            % Encrypting the result of XOR between counter (FormattedCounter) 
            % and the initialization vector (IV) 
            EncryptedCounter = AES_encrypt(Counter,Key);
            Counter = increaseCounter(Counter);
    
            % Xoring the encrypted counter with a block of the plain text
            LastCipherText = bitxor(EncryptedCounter(end-Remainder+1:end),...
                LastPlainText);
    
            % Combining all the blocks with the last one
            CipherText = reshape(CipherText,1,[]);
            CipherText = [CipherText,LastCipherText];
        end
    end
    lastCounter = Counter;
end

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