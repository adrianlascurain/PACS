function [encrypted_message] = AES_CTR_par_encrypt(message,Key,IV)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
originalLen = length(message);
if mod(originalLen,16)~=0
    lenOfPaddedMessage = ceil(originalLen/16)*16;
    PaddedMessage = [message zeros(1,lenOfPaddedMessage-originalLen)];
else
    lenOfPaddedMessage = originalLen;
    PaddedMessage = message;
end

state = double(reshape(PaddedMessage,4,4,[]));
encrypted_message = zeros(4,4,ceil(lenOfPaddedMessage/16));
counter = 1:ceil(lenOfPaddedMessage/16);
% Prueba
%IV = reshape(IV(1:8),4,[]);

parfor i=1:ceil(lenOfPaddedMessage/16)
    charcounter = double(reshape(num2str(counter(i),'%016.f'),4,[]));
    CIV = mod(bitxor(charcounter,IV),2^8);
    %CIV = [IV charcounter];
    encrypted_CIV = AES_encrypt(CIV,Key);
    encrypted_message(:,:,i) = bitxor(state(:,:,i),...
        encrypted_CIV);
end
encrypted_message = reshape(encrypted_message,1,[]);
end