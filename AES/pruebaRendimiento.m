im = imread("tomo.jpg");
bytes = {im};
[bytesCifrados,contadores] = cipherCellArray({bytes},1:16,1:16);
