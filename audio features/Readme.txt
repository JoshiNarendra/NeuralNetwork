% First of all read the contents of a folder/directory containing .wav audio
% files using the command:
%       Files=dir('Name_of _folder'); 

Now there are 5 scripts that you will need:
%   -songfeatures
%   -mfcc
%   -rasta
%   -wav_entropy
%   -histogram

% Once the "Files" has been created copy the above 5 scripts into the folder that you
% just read. Then make that folder your 'Current Folder' in Matlab and
% simply run first script, i.e. the one called "songfeatures"

>> songfeatures


% It will generate a matrix with the MFCC,RASTA,Energy and Entropy features
% of each audio recording. Each recording will give 30 features: 13 MFCC, 13
% RASTA, 1 Energy (copied twice) and 1 Entropy (copied twice)