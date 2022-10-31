
%1 LOADING AND SECTIONING IMAGE
%2 PROCESSING 
%3 GRAPHING
%4 SECTIONING THE ROI

%The overall functioning of this program is to obtain the "Error" as the
%difference between the original image and the image once the Fourier
%Transform and then the Inverse Fourier Transform are applied. This image
%is expected, ideally, to be cero. Values outside of cero may suggest an
%anomaly, be it from image distortion, image noise or an anomaly of
%physical and medical relevance. 


%Run (1) to (3) once the mask has been generated and applied as wished.
%Run (4) and apply the mask. 
    %Once the image is shown on display, make a polygon figure through many
    %clicks to surround the ROI. Then left click and select "Create mask"


clear all; close all;

%1 LOADING AND SECTIONING IMAGE

img0 = imread("C:\Users\Kevin\OneDrive\Imágenes\ROIP1.png");
Imag_orig = double(rgb2gray(img0));
%Corte = imcrop(img0, [725.5 466.5 405 390]);  %this specific resizing did not work

%Uncomment to cut down the section for the mask
corte_de_estudio = imcrop(img0);

%2 PROCESSING 

%Any image can be used for this processing as "anomalia_0", either the
%image with the mask on or the whole image or a section of the image. Just
%change the declaration of "anomalia_0"

%rgb2gray() will convert the image into gray scale
anomalia_0 = im2gray(Imag_orig);                

%size() returns a tuple with the size of the dimensions of the image
%this gets a new size c to resize the image: c is the largest of the
%dimensions of the image to make sure it is squared
[A,B] = size(anomalia_0);    
if A < B;
    c = B;
else
    c = A;
end

%converting the matrix's data into floats and resizing the image
Anomalia_0 = double(imresize(anomalia_0,[c c]));       

%%%%% Increasing the image section size
C = 256;
Anomalia_0 = double(imresize(Anomalia_0,[C C]));
%Corte_de_estudio = double(imresize(Corte_de_estudio,[C C]));


%%%%% Applying Fast Fourier Transform function
ft = fftshift(fft2(Anomalia_0));


%%%%%Band Pass Filter, it will allow for the center to get through the filter
%d = 2/c;

%creating a grid
[X, Y]=meshgrid(-((C)/2):1:(C)/2);
d=4;

%resizing the grids X and Y into 256x256
X=imresize(X,[C C]);    Y=imresize(Y,[C C]);

circ1=((X).^2+(Y).^2<=d.^2);
Filtro = double(circ1);

%%%%% Fourier Transform in the central order
FT_fil = ft.*Filtro;
mesh(abs(FT_fil))

%%%%% Inverse Fourier Transform
anomalia_fil = (ifft2(FT_fil)); 
Anomalia_fil = abs(anomalia_fil); 

%%%%% Obtaining the difference between the original image and the obtained
%%%%% image through the fourier transform and inverse fouirer transform.
%%%%% This is expected to be cero.
Error = Anomalia_fil - Anomalia_0;

%3 GRAPHING
figure
	mesh(Anomalia_0), colormap bone %last pattern
	title('Image Section');
    
    figure
	imshow(img0), colormap bone %last pattern
	title('Original Image');
    
        figure
	mesh(Anomalia_fil), colormap bone %last pattern
	title('FFT applied to the section');

  figure
	mesh(Error), colormap bone %last pattern
	title('Error');


%4 SECTIONING THE ROI

%%%%% Sectioning the ROI
T = uint8(Corte_de_estudio);


%%%%% The figure's graph is necessary, otherwise, use the function as:
h = roipoly(T);         %comment in unncessary 
%%%%% iunt8 format is NOT necessary, the purpose for this is a better
%%%%% visualization.

figure;
imshow(T)
h = roipoly;




%uncomment to make the section mask drawing down the polygon, only if it is
%the first time

%%%%%% In "h" only the mask "mask" is created when finishing the polygon
%%%%%% drawing, then click left to select "create mask"

%%%%% Mask in multipliable matrix element of type "double"
mask_1 = double(h);



    

%%%%% It is recommended to use roipoly method and save the masks created in
%%%%% different folders and then call them. Otherwise the mask would have
%%%%% to be redone. 
load("C:\Users\Kevin\Searches\Downloads\Mask_50.mat")

%%%%% after load and create the binary mask, last code line should be
%%%%% commented to build the ROI mask in "roipoly"


%%%%% Results analysis of the anomaly "Error"
anoma = Error.*mask_1;
M = min(min(anoma));
if M < 0
    anomalia = anoma +abs(M);                       
else
    anomalia = anoma - M;
end
anomalia=anomalia.*mask_1;
for i=1:C
    for j=1:C
        
        if anomalia(i,j) == 0
            Anomalia(i,j) = NaN;
        else
            Anomalia(i,j) = anomalia(i,j);
        end
        
    end
end
        figure
	mesh(Anomalia), colormap bone %last pattern
	title('Imagen a analisis y discutir');