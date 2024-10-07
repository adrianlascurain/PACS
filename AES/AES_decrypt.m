function [PlainText] = AES_decrypt(CypherText,key)
%UNTITLED Summary of this function goes here
%Detailed explanation goes here

encrypted_message = CypherText;

if length(encrypted_message) == 32
    state = reshape(hex2dec(reshape(encrypted_message,2,[])'),4,[]);
else
    state = double(reshape(encrypted_message,4,[]));
end

if ~isnumeric(key)
    key = reshape(hex2dec(reshape(key,2,[])'),4,[]);
end
key = reshape(key,4,[]);

[~,Nk] = size(key);

if Nk == 4
    numberOfRounds = 10;
elseif Nk == 6
    numberOfRounds = 12;
elseif Nk == 8
    numberOfRounds = 14;
else
    errordlg("clave invalida")
    return 
end

% AES decryption Start

Keys = KeyExpansion(key,Nk,numberOfRounds);
for i=2:numberOfRounds
    Keys(:,:,i) = InvMixColumns(Keys(:,:,i));
end
state = AddRoundKey(state, Keys(:,:,end));     % AddRoundKey or whitening (XOR)

for i=numberOfRounds:-1:2
    state = InvSubBytes(state);
    state = InvShiftRows(state);
    state = InvMixColumns(state);
    state = AddRoundKey(state, Keys(:,:,i));
end

% Final Round 
  state = InvSubBytes(state);
  state = InvShiftRows(state);
  state = AddRoundKey(state, Keys(:,:,1));
  PlainText = state;
end

% KEY EXPANSION
function expandedKeys = KeyExpansion(inputKey,Nk,Nr)

Rcon = [1 2 4 8 16 32 64 128 27 54;zeros(3,10)];
expandedKeys = zeros(4,4*(Nr+1));
expandedKeys(:,1:Nk) = inputKey;

if Nk<=6
    for i=Nk: 4 * (Nr + 1)-1
        temp = expandedKeys(:,i);
        if mod(i,Nk)==0
            temp = SubBytes(circshift(temp,-1));
            temp = bitxor(temp,Rcon(:, i / Nk));
        end
        temp = bitxor(temp,expandedKeys(:,i-Nk+1));
        expandedKeys (:,i+1) = temp;
    end
elseif Nk>6
    for i=Nk: 4 * (Nr + 1)-1
        temp = expandedKeys(:,i);
        if mod(i,Nk)==0
            temp = SubBytes(circshift(temp,-1));
            temp = bitxor(temp,Rcon(:, i / Nk));
        elseif mod(i,Nk)==4
            temp = SubBytes(temp);
        end
        temp = bitxor(temp,expandedKeys(:,i-Nk+1));
        expandedKeys (:,i+1) = temp;
    end
end
expandedKeys = reshape(expandedKeys,4,4,[]);

end

% ADD ROUND KEY - XOR
function state = AddRoundKey(state,roundKey)

state = bitxor(state,roundKey);
end

% SUB-BYTES
function state = SubBytes(state)

% This S-box was transformed from hexadecimal to decimal in order to make 
% it easier to storage in a matlab array of 16x16, after then was 
% transposed to match with matlab indexing, you can index using
% hexadecimal or the corresponding decimal number of the table.

% Indexing using hexadecimal
% Example : Sbox(0x00+1) = 99 dec that correspond with 63 hex
% Example : Sbox(0xca+1) = 116 dec that correspond with 74 hex

% Indexing using decimal (same cases)
% Example : Sbox(0+1) = 99 dec that correspond with 63 hex
% Example : Sbox(202+1) = 116 dec that correspond with 74 hex

Sbox = [99,202,183,4,9,83,208,81,205,96,224,231,186,112,225,140;...
        124,130,253,199,131,209,239,163,12,129,50,200,120,62,248,161;...
        119,201,147,35,44,0,170,64,19,79,58,55,37,181,152,137;...
        123,125,38,195,26,237,251,143,236,220,10,109,46,102,17,13;...
        242,250,54,24,27,32,67,146,95,34,73,141,28,72,105,191;...
        107,89,63,150,110,252,77,157,151,42,6,213,166,3,217,230;...
        111,71,247,5,90,177,51,56,68,144,36,78,180,246,142,66;...
        197,240,204,154,160,91,133,245,23,136,92,169,198,14,148,104;...
        48,173,52,7,82,106,69,188,196,70,194,108,232,97,155,65;...
        1,212,165,18,59,203,249,182,167,238,211,86,221,53,30,153;...
        103,162,229,128,214,190,2,218,126,184,172,244,116,87,135,45;...
        43,175,241,226,179,57,127,33,61,20,98,234,31,185,233,15;...
        254,156,113,235,41,74,80,16,100,222,145,101,75,134,206,176;...
        215,164,216,39,227,76,60,255,93,94,149,122,189,193,85,84;...
        171,114,49,178,47,88,159,243,25,11,228,174,139,29,40,187;...
        118,192,21,117,132,207,168,210,115,219,121,8,138,158,223,22];

state = Sbox(state+1);

end

% INVERSE SUB BYTES
function [state] = InvSubBytes(state)

ISbox = [82,124,84,8,114,108,144,208,58,150,71,252,31,96,160,23;...
        9,227,123,46,248,112,216,44,145,172,241,86,221,81,224,43;...
        106,57,148,161,246,72,171,30,17,116,26,62,168,127,59,4;...
        213,130,50,102,100,80,0,143,65,34,113,75,51,169,77,126;...
        48,155,166,40,134,253,140,202,79,231,29,198,136,25,174,186;...
        54,47,194,217,104,237,188,63,103,173,41,210,7,181,42,119;...
        165,255,35,36,152,185,211,15,220,53,197,121,199,74,245,214;...
        56,135,61,178,22,218,10,2,234,133,137,32,49,13,176,38;...
        191,52,238,118,212,94,247,193,151,226,111,154,177,45,200,225;...
        64,142,76,91,164,21,228,175,242,249,183,219,18,229,235,105;...
        163,67,149,162,92,70,88,189,207,55,98,192,16,122,187,20;...
        158,68,11,73,204,87,5,3,206,232,14,254,89,159,60,99;...
        129,196,66,109,93,167,184,1,240,28,170,120,39,147,131,85;...
        243,222,250,139,101,141,179,19,180,117,24,205,128,201,83,33;...
        215,233,195,209,182,157,69,138,230,223,190,90,236,156,153,12;...
        251,203,78,37,146,132,6,107,115,110,27,244,95,239,97,125];

state = ISbox(state+1);
end

% INVERSE SHIFT ROWS
function state = InvShiftRows(state)

state (2,:) = circshift(state(2,:),1);
state (3,:) = circshift(state(3,:),2);
state (4,:) = circshift(state(4,:),3);
end

% INVERSE MIX COLUMNS
function [state] = InvMixColumns(state)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
mul.mul9 = [0,144,59,171,118,230,77,221,236,124,215,71,154,10,161,49;...
        9,153,50,162,127,239,68,212,229,117,222,78,147,3,168,56;...
        18,130,41,185,100,244,95,207,254,110,197,85,136,24,179,35;...
        27,139,32,176,109,253,86,198,247,103,204,92,129,17,186,42;...
        36,180,31,143,82,194,105,249,200,88,243,99,190,46,133,21;...
        45,189,22,134,91,203,96,240,193,81,250,106,183,39,140,28;...
        54,166,13,157,64,208,123,235,218,74,225,113,172,60,151,7;...
        63,175,4,148,73,217,114,226,211,67,232,120,165,53,158,14;...
        72,216,115,227,62,174,5,149,164,52,159,15,210,66,233,121;...
        65,209,122,234,55,167,12,156,173,61,150,6,219,75,224,112;...
        90,202,97,241,44,188,23,135,182,38,141,29,192,80,251,107;...
        83,195,104,248,37,181,30,142,191,47,132,20,201,89,242,98;...
        108,252,87,199,26,138,33,177,128,16,187,43,246,102,205,93;...
        101,245,94,206,19,131,40,184,137,25,178,34,255,111,196,84;...
        126,238,69,213,8,152,51,163,146,2,169,57,228,116,223,79;...
        119,231,76,220,1,145,58,170,155,11,160,48,237,125,214,70];

mul.mul11 = [0,176,123,203,246,70,141,61,247,71,140,60,1,177,122,202;...
        11,187,112,192,253,77,134,54,252,76,135,55,10,186,113,193;...
        22,166,109,221,224,80,155,43,225,81,154,42,23,167,108,220;...
        29,173,102,214,235,91,144,32,234,90,145,33,28,172,103,215;...
        44,156,87,231,218,106,161,17,219,107,160,16,45,157,86,230;...
        39,151,92,236,209,97,170,26,208,96,171,27,38,150,93,237;...
        58,138,65,241,204,124,183,7,205,125,182,6,59,139,64,240;...
        49,129,74,250,199,119,188,12,198,118,189,13,48,128,75,251;...
        88,232,35,147,174,30,213,101,175,31,212,100,89,233,34,146;...
        83,227,40,152,165,21,222,110,164,20,223,111,82,226,41,153;...
        78,254,53,133,184,8,195,115,185,9,194,114,79,255,52,132;...
        69,245,62,142,179,3,200,120,178,2,201,121,68,244,63,143;...
        116,196,15,191,130,50,249,73,131,51,248,72,117,197,14,190;...
        127,207,4,180,137,57,242,66,136,56,243,67,126,206,5,181;...
        98,210,25,169,148,36,239,95,149,37,238,94,99,211,24,168;...
        105,217,18,162,159,47,228,84,158,46,229,85,104,216,19,163];

mul.mul13 = [0,208,187,107,109,189,214,6,218,10,97,177,183,103,12,220;...
        13,221,182,102,96,176,219,11,215,7,108,188,186,106,1,209;...
        26,202,161,113,119,167,204,28,192,16,123,171,173,125,22,198;...
        23,199,172,124,122,170,193,17,205,29,118,166,160,112,27,203;...
        52,228,143,95,89,137,226,50,238,62,85,133,131,83,56,232;...
        57,233,130,82,84,132,239,63,227,51,88,136,142,94,53,229;...
        46,254,149,69,67,147,248,40,244,36,79,159,153,73,34,242;...
        35,243,152,72,78,158,245,37,249,41,66,146,148,68,47,255;...
        104,184,211,3,5,213,190,110,178,98,9,217,223,15,100,180;...
        101,181,222,14,8,216,179,99,191,111,4,212,210,2,105,185;...
        114,162,201,25,31,207,164,116,168,120,19,195,197,21,126,174;...
        127,175,196,20,18,194,169,121,165,117,30,206,200,24,115,163;...
        92,140,231,55,49,225,138,90,134,86,61,237,235,59,80,128;...
        81,129,234,58,60,236,135,87,139,91,48,224,230,54,93,141;...
        70,150,253,45,43,251,144,64,156,76,39,247,241,33,74,154;...
        75,155,240,32,38,246,157,77,145,65,42,250,252,44,71,151];

mul.mul14 = [0,224,219,59,173,77,118,150,65,161,154,122,236,12,55,215;...
        14,238,213,53,163,67,120,152,79,175,148,116,226,2,57,217;...
        28,252,199,39,177,81,106,138,93,189,134,102,240,16,43,203;...
        18,242,201,41,191,95,100,132,83,179,136,104,254,30,37,197;...
        56,216,227,3,149,117,78,174,121,153,162,66,212,52,15,239;...
        54,214,237,13,155,123,64,160,119,151,172,76,218,58,1,225;...
        36,196,255,31,137,105,82,178,101,133,190,94,200,40,19,243;...
        42,202,241,17,135,103,92,188,107,139,176,80,198,38,29,253;...
        112,144,171,75,221,61,6,230,49,209,234,10,156,124,71,167;...
        126,158,165,69,211,51,8,232,63,223,228,4,146,114,73,169;...
        108,140,183,87,193,33,26,250,45,205,246,22,128,96,91,187;...
        98,130,185,89,207,47,20,244,35,195,248,24,142,110,85,181;...
        72,168,147,115,229,5,62,222,9,233,210,50,164,68,127,159;...
        70,166,157,125,235,11,48,208,7,231,220,60,170,74,113,145;...
        84,180,143,111,249,25,34,194,21,245,206,46,184,88,99,131;...
        90,186,129,97,247,23,44,204,27,251,192,32,182,86,109,141];


mul_str = ["mul14","mul11","mul13","mul9";...
            "mul9","mul14","mul11","mul13";...
            "mul13","mul9","mul14","mul11";...
            "mul11","mul13","mul9","mul14"];

aux = zeros(4,4,4);
for i = 1:4
    for j = 1:4
        for d=1:4
            aux(d,j,i) =mul.(mul_str(i,d))(state(d,j)+1);
        end
    end 
end

aux = reshape(aux,4,1,16);
temp = zeros(1,16);

for i = 1:16
    temp(i) = bitxor(bitxor(aux(1,1,i),aux(2,1,i)),bitxor(aux(3,1,i)...
        ,aux(4,1,i)));
end
state = reshape(temp,4,[])';

end