function CypherText = AES_encrypt(PlainText,key)
%UNTITLED2 Summary of this function goes here

message = PlainText;
if length(message) == 32
    state = reshape(hex2dec(reshape(message,2,[])'),4,[]);
else
    state = double(reshape(message,4,[]));
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

% AES encryption Start

% Initial Round
Keys = KeyExpansion(key,Nk,numberOfRounds);
state = AddRoundKey(state, Keys(:,:,1));     % AddRoundKey or whitening (XOR)

% Rounds

for i=2:numberOfRounds
    state = SubBytes(state);
    state = ShiftRows(state);  
    state = MixColumns(state);
    state = AddRoundKey(state, Keys(:,:,i));   
end

% Final Round 
state = SubBytes(state);
state = ShiftRows(state);
state = AddRoundKey(state, Keys(:,:,end));
CypherText = state;
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

% SHIFT ROWS
function state = ShiftRows(state)

state (2,:) = circshift(state(2,:),-1);
state (3,:) = circshift(state(3,:),-2);
state (4,:) = circshift(state(4,:),-3);
end

% MIX COLUMNS
function state = MixColumns(state)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

mul.mul2 = [0,32,64,96,128,160,192,224,27,59,91,123,155,187,219,251;...
            2,34,66,98,130,162,194,226,25,57,89,121,153,185,217,249;...
            4,36,68,100,132,164,196,228,31,63,95,127,159,191,223,255;...
            6,38,70,102,134,166,198,230,29,61,93,125,157,189,221,253;...
            8,40,72,104,136,168,200,232,19,51,83,115,147,179,211,243;...
            10,42,74,106,138,170,202,234,17,49,81,113,145,177,209,241;...
            12,44,76,108,140,172,204,236,23,55,87,119,151,183,215,247;...
            14,46,78,110,142,174,206,238,21,53,85,117,149,181,213,245;...
            16,48,80,112,144,176,208,240,11,43,75,107,139,171,203,235;...
            18,50,82,114,146,178,210,242,9,41,73,105,137,169,201,233;...
            20,52,84,116,148,180,212,244,15,47,79,111,143,175,207,239;...
            22,54,86,118,150,182,214,246,13,45,77,109,141,173,205,237;...
            24,56,88,120,152,184,216,248,3,35,67,99,131,163,195,227;...
            26,58,90,122,154,186,218,250,1,33,65,97,129,161,193,225;...
            28,60,92,124,156,188,220,252,7,39,71,103,135,167,199,231;...
            30,62,94,126,158,190,222,254,5,37,69,101,133,165,197,229];

mul.mul3 = [0,48,96,80,192,240,160,144,155,171,251,203,91,107,59,11;...
            3,51,99,83,195,243,163,147,152,168,248,200,88,104,56,8;...
            6,54,102,86,198,246,166,150,157,173,253,205,93,109,61,13;...
            5,53,101,85,197,245,165,149,158,174,254,206,94,110,62,14;...
            12,60,108,92,204,252,172,156,151,167,247,199,87,103,55,7;...
            15,63,111,95,207,255,175,159,148,164,244,196,84,100,52,4;...
            10,58,106,90,202,250,170,154,145,161,241,193,81,97,49,1;...
            9,57,105,89,201,249,169,153,146,162,242,194,82,98,50,2;...
            24,40,120,72,216,232,184,136,131,179,227,211,67,115,35,19;...
            27,43,123,75,219,235,187,139,128,176,224,208,64,112,32,16;...
            30,46,126,78,222,238,190,142,133,181,229,213,69,117,37,21;...
            29,45,125,77,221,237,189,141,134,182,230,214,70,118,38,22;...
            20,36,116,68,212,228,180,132,143,191,239,223,79,127,47,31;...
            23,39,119,71,215,231,183,135,140,188,236,220,76,124,44,28;...
            18,34,114,66,210,226,178,130,137,185,233,217,73,121,41,25;...
            17,33,113,65,209,225,177,129,138,186,234,218,74,122,42,26];

mul_str = ["mul2","mul3","mul1","mul1";...
            "mul1","mul2","mul3","mul1";...
            "mul1","mul1","mul2","mul3";...
            "mul3","mul1","mul1","mul2"];

aux = zeros(4,4,4);
for i = 1:4
    for j = 1:4
        for d=1:4
            if mul_str(i,d) == "mul1"
                aux(d,j,i) = state(d,j);
            else
                aux(d,j,i) =mul.(mul_str(i,d))(state(d,j)+1);
            end
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