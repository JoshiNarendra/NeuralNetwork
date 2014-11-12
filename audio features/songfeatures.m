%this script needs to be in the same directory as the following scripts :
%   -mfcc
%   -rasta
%   -wav_entropy
%   -histogram
%First of all read the contents of a folder/directory containing .wav audio
%files using the command:
%       Files=dir('Name_of_folder');
%and after that, copy this and the above 4 scripts into the folder that you
%just read. Then make that folder your 'Current Folder' in Matlab and
% simply run this script
%It will generate a matrix with the MFCC,RASTA,Energy and Entropy features
%of each audio recording. Each recording will give 30 features: 13 MFCC, 13
%RASTA, 1 Energy (copied twice) and 1 Entropy (copied twice)

bigInput=zeros(30,length(Files)-2);
for t=1:(length(Files)-2)
    wavFile=wavread(Files(t+2).name);
    ceps=mfcc(wavFile);

    rastas=rasta(ceps);
    
    Energy = (1/(length(wavFile))) * sum(wavFile.^2);
    
    Entropy=wav_entropy(wavFile');
    
    [row column]=size(ceps);
    
    sumCeps=sum(ceps,2);
    avgCeps=(1/column)*sumCeps; %calculates overall mfcc for the whole file
    
    sumRastas=sum(rastas,2);
    avgRastas=(100/column)*sumRastas;      %rastas are multiplied by 100 to make them comparable in magnitude to neuronal spikes
    
    input=[avgCeps;avgRastas;Energy;Energy;Entropy;Entropy];
    
    bigInput(:,t)= input; %combines features for all recordings in one matrix
end;