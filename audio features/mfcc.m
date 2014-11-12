%NOTE:make sure to convert .wav file to a matrix first, using wavread('file.wav')  
%mfcc - Mel frequency cepstrum coefficient analysis.
%   [ceps] = ...
%			mfcc(input, samplingRate, [frameRate])
% Find the cepstral coefficients (ceps) corresponding to the
% input. 
%  -- Malcolm Slaney, August 1993
% Modified a bit to make testing an algorithm easier... 4/15/94
% Fixed Cosine Transform (indices of cos() were swapped) - 5/26/95
% Added optional frameRate argument - 6/8/95
% Added proper filterbank reconstruction using inverse DCT - 10/27/95
% Added filterbank inversion to reconstruct spectrum - 11/1/95
% Removed the optional outputs to simplify the code - 11/28/2012 --Narendra

% (c) 1998 Interval Research Corporation  

function [ceps] = mfcc(input, samplingRate, frameRate)
global mfccDCTMatrix mfccFilterWeights

[r c] = size(input);
if (r > c) 
	input=input';
end

%	Filter bank parameters
lowestFrequency = 133.3333;
linearFilters = 13;
linearSpacing = 66.66666666;
logFilters = 27;
logSpacing = 1.0711703;
fftSize = 512;
cepstralCoefficients = 13;
windowSize = 400;
windowSize = 256;		% Standard says 400, but 256 makes more sense
				% Really should be a function of the sample
				% rate (and the lowestFrequency) and the
				% frame rate.
if (nargin < 2) samplingRate = 16000; end;
if (nargin < 3) frameRate = 100; end;

% Keep this around for later....
totalFilters = linearFilters + logFilters;

% Now figure the band edges.  Interesting frequencies are spaced
% by linearSpacing for a while, then go logarithmic.  First figure
% all the interesting frequencies.  Lower, center, and upper band
% edges are all consequtive interesting frequencies. 

freqs = lowestFrequency + (0:linearFilters-1)*linearSpacing;
freqs(linearFilters+1:totalFilters+2) = ...
		      freqs(linearFilters) * logSpacing.^(1:logFilters+2);

lower = freqs(1:totalFilters);
center = freqs(2:totalFilters+1);
upper = freqs(3:totalFilters+2);

% We now want to combine FFT bins so that each filter has unit
% weight, assuming a triangular weighting function.  First figure
% out the height of the triangle, then we can figure out each 
% frequencies contribution
mfccFilterWeights = zeros(totalFilters,fftSize);
triangleHeight = 2./(upper-lower);
fftFreqs = (0:fftSize-1)/fftSize*samplingRate;

for chan=1:totalFilters
	mfccFilterWeights(chan,:) = ...
  (fftFreqs > lower(chan) & fftFreqs <= center(chan)).* ...
   triangleHeight(chan).*(fftFreqs-lower(chan))/(center(chan)-lower(chan)) + ...
  (fftFreqs > center(chan) & fftFreqs < upper(chan)).* ...
   triangleHeight(chan).*(upper(chan)-fftFreqs)/(upper(chan)-center(chan));
end
%semilogx(fftFreqs,mfccFilterWeights')
%axis([lower(1) upper(totalFilters) 0 max(max(mfccFilterWeights))])

hamWindow = 0.54 - 0.46*cos(2*pi*(0:windowSize-1)/windowSize);

if 0					% Window it like ComplexSpectrum
	windowStep = samplingRate/frameRate;
	a = .54;
	b = -.46;
	wr = sqrt(windowStep/windowSize);
	phi = pi/windowSize;
	hamWindow = 2*wr/sqrt(4*a*a+2*b*b)* ...
		(a + b*cos(2*pi*(0:windowSize-1)/windowSize + phi));
end

% Figure out Discrete Cosine Transform.  We want a matrix
% dct(i,j) which is totalFilters x cepstralCoefficients in size.
% The i,j component is given by 
%                cos( i * (j+0.5)/totalFilters pi )
% where we have assumed that i and j start at 0.
mfccDCTMatrix = 1/sqrt(totalFilters/2)*cos((0:(cepstralCoefficients-1))' * ...
				(2*(0:(totalFilters-1))+1) * pi/2/totalFilters);
mfccDCTMatrix(1,:) = mfccDCTMatrix(1,:) * sqrt(2)/2;

%imagesc(mfccDCTMatrix);

% Filter the input with the preemphasis filter.  Also figure how
% many columns of data we will end up with.
if 1
	preEmphasized = filter([1 -.97], 1, input);
else
	preEmphasized = input;
end
windowStep = samplingRate/frameRate;
cols = fix((length(input)-windowSize)/windowStep);

% Allocate all the space we need for the output arrays.
ceps = zeros(cepstralCoefficients, cols);

% Ok, now let's do the processing.  For each chunk of data:
%    * Window the data with a hamming window,
%    * Shift it into FFT order,
%    * Find the magnitude of the fft,
%    * Convert the fft data into filter bank outputs,
%    * Find the log base 10,
%    * Find the cosine transform to reduce dimensionality.
for start=0:cols-1
    first = start*windowStep + 1;
    last = first + windowSize-1;
    fftData = zeros(1,fftSize);
    fftData(1:windowSize) = preEmphasized(first:last).*hamWindow;
    fftMag = abs(fft(fftData));
    earMag = log10(mfccFilterWeights * fftMag');

    ceps(:,start+1) = mfccDCTMatrix * earMag;
end