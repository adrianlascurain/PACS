function [encrypted_image] = AES_CTR_parIM_encrypt(Im,Key,IV)
%This function encrypts an image using AES in CTR mode

[r,c,d] = size(Im);
Im = double(Im);

if mod(r*c*d,16)~=0
    errordlg('Dimensiones de imagen no soportadas para encriptación')
    return
end

encrypted_image = zeros(4,4,r*c*d/16);
counter = 1:ceil(r*c*d/16);
Im = reshape(Im,4,4,[]);

parfor i=1:ceil(r*c*d/16)
    charcounter = double(reshape(num2str(counter(i),'%016.f'),4,[]));
    CIV = bitxor(charcounter,IV);
    encrypted_CIV = AES_encrypt(CIV,Key);
    encrypted_image(:,:,i) = bitxor(Im(:,:,i),...
        encrypted_CIV);
end

encrypted_image = uint8(reshape(encrypted_image,r,c,d));
end