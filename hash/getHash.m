function [encodedHash] = getHash(password,salt,controlValue)
%Hash password using SHA-512 and salt value
%   This function takes a password and a salt value to get a hash using
%   SHA-512, also concatenates a control value
    password = uint16(password);
    password = typecast(password,'uint8');
    salt = sscanf(salt,'%2x')';
    saltedPaswword = uint8([password,salt]);
    hash = DataHash(saltedPaswword,'HEX','bin');
    encodedHash = [controlValue,salt,hash];
end