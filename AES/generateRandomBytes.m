function [randomBytes] = generateRandomBytes(lengthRandom)
% Generate random bytes 
%   Generate secure random integers for counters using Java secure library
    arguments
        lengthRandom(1,1) {mustBePositive,mustBeInteger,mustBeReal}
    end
    
    % create a java SecureRandom object to have acces to lirary functions
    % and pre allocate randomBytes array
    secureRandom = java.security.SecureRandom();
    randomBytes = zeros(1,lengthRandom);

    % Generate random bytes (0-255)
    for i = 1 : lengthRandom
        randomBytes(i) = secureRandom.nextInt(256);
    end

end