function [ErrorRate] = test
%%%%%%%%%%%%%%%%%%%%%%%%%%%      load data      %%%%%%%%%%%%%%%%%%%%%%%%%%
adult_test=load('adults_test.txt');
juveniles_test=load('juveniles_test.txt');

allInputs=[adult_test juveniles_test];
TotalInputs=size(allInputs,2);

%%%%%%%%%%%%%%%%%%%%%modify inputs to emphasize differences%%%%%%%%%%%%%%

allInputs([1 29 30],:)=(-1)*(allInputs([1 29 30],:));
allInputs([3 15 16 17],:)=(-5)*(allInputs([3 15 16 17],:));
allInputs([29 30],:)=(5)*(allInputs([29 30],:));
allInputs([4 18:26],:)=abs(20*(allInputs([4 18:26],:)));
allInputs([2 7:11],:)=(-50)*(allInputs([2 7:11],:));
allInputs([5 6 12 13],:)=(-100)*(allInputs([5 6 12 13],:));
allInputs([27 28],:)=20000*(allInputs([27 28],:));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%THE Spiking Neural Network%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spiking network with STDP
% Created by Eugene M.Izhikevich.                February 3, 2004
% Modified to allow arbitrary delay distributions.  April 16,2008
% Modified to work with song files                December 7,2012 
%                                                --Narendra Joshi        
N1=30;      %neurons in layer 1          
N2=30;      %neurons in layer 2             
N=N1+N2;    % total number
post=load('synaptic_connections.txt');  % load synaptic connections
syn_wt=load('synaptic_weights.txt');    % load the trained synaptic weights

firings=[0 0];                 % 'firings' stores time in ms (column 1) and the neurons firing at that time (column 2)
Hits=0;

for sec=1:TotalInputs                  % simulation of 10 sec
    v = -65*ones(N,1);             % initial values(neuronal resting potential)
    output=0;
    for t=1:10                              % each song stimulus is run 10 times through the network
        I=zeros(N+1,1);                     % 'I' values will be used as the current input voltage at a post-synaptic target
        I(1:30)=I(1:30)+allInputs(1:30,sec);
        fired = find(v>=30);                % indices of fired neurons
        v(fired)=-65;
        
        firings=[firings;t+0*fired,fired]; %update the firings array to include names of the neurons that fired this time (at t ms)
        k=size(firings,1);
        while firings(k,1)==t
            if firings(k,2) <= N1
                ind = post(firings(k,2),:);   % ind is the list of names of post-synaptic targets(1-N) that are connected to neuron at firings(k,2)
                I(ind)=I(ind)+syn_wt(firings(k,2),:)';
            else
                I(N+1)=I(N+1)+syn_wt(firings(k,2),1);
            end;
            k=k-1;
        end;
        
        v=v+I(1:N);                       %the incoming action potential increases or decreases the membrane potential depending on synaptic weight
        output=output+I(N+1);
    end;
%     figure(1);
%     plot(firings(:,1),firings(:,2),'.');
%     xlabel('time in millisecond');
%     ylabel('Name(#) of firing neurons');
%     head=sprintf('Pattern of neuronal firing at time %.0f second with output',sec);
%     title(head);
%     axis([0 t 0 N]); drawnow;
%     firings=[0 0];
    
    if (allInputs(31,sec)==1) && (output >= 20)
        Hits = Hits+1;
    elseif (allInputs(31,sec)==0) && (output < 20)
        Hits = Hits+1;
    end;
    
end;
ErrorRate=(TotalInputs-Hits)/TotalInputs;