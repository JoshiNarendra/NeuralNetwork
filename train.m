function ErrorRate = train
%%%%%%%%%%%%%%%%%%%%%%%%%%%      load data      %%%%%%%%%%%%%%%%%%%%%%%%%%
adult_train=load('adults_train.txt');
juveniles_train=load('juveniles_train.txt');

allInputs=[adult_train juveniles_train];
TotalInputs=size(allInputs,2);
seq=randperm(TotalInputs);
allInputs=allInputs(:,seq);

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
%One limitation: in an actual brain, neurons will NOT have equal chance
%of forming synapse with all other neurons. closer neurons = higher chance        
N1=30;      %neurons in layer 1          
N2=30;      %neurons in layer 2             
N=N1+N2;    % total number
smax=80;      % maximal synaptic strength
smin=-80;
syn_wt=load('synaptic_weights.txt');    % load synaptic weights
post=load('synaptic_connections.txt');

v = -65*ones(N,1);   % initial values(neuronal resting potential)
firings=[0 0];       % 'firings' stores time in ms (column 1) and the neurons firing at that time (column 2)
lastFired=[];
cutoff=20;
Hits=0;

for sec=1:TotalInputs
    output=0;
    for t=1:10
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
        
        %%%%%%%%%%now update synaptic weights using STDP%%%%%%%%%%%%%%%%%%%%%%
        lenFired=length(fired);
        presyn=[0 0];        %presyn stores the presynaptic connections to neurons that fired in this loop
        for m=1:lenFired
            [x,y]=find(post==fired(m));
            presyn=[presyn;x,y];
        end;
        augment=intersect(presyn(:,1),lastFired); %'augment' (array of neurons 1 to N1) contains neurons that fired in last cycle and
        Xco=[];                                   % have connections with neurons that fired in this cycle through a synapse that needs to be augmented
        for g=1:length(augment)
            [xcoordinate,yco]=find(presyn == augment(g));
            Xco=[Xco;xcoordinate];
        end;
        Str=presyn(Xco,:);
        
        if allInputs(31,sec)==1
            syn_wt(Str(:,1),Str(:,2))=min(smax,syn_wt(Str(:,1),Str(:,2))+0.2);        %this is where synaptic weights get incremented to reach a max of sm
            syn_wt(find(fired>N1),1)= syn_wt(find(fired>N1),1)+1;
        else
            syn_wt(Str(:,1),Str(:,2))=min(smax,syn_wt(Str(:,1),Str(:,2))-0.1);
            %syn_wt(find(fired>N1),1)= syn_wt(find(fired>N1),1)-0.1;
        end;
        
        %%%%%%%%%to decrease synaptic weight when firing sequence is opposite
        lenFired=length(lastFired);
        presyn=[0 0];        %presyn stores the presynaptic connections to neurons that fired in this loop
        for m=1:lenFired
            [x,y]=find(post==lastFired(m));
            presyn=[presyn;x,y];
        end;
        augment=intersect(presyn(:,1),fired);
        Xco=[];
        for g=1:length(augment)
            [xcoordinate,yco]=find(presyn == augment(g));
            Xco=[Xco;xcoordinate];
        end;
        Str=presyn(Xco,:);
        if allInputs(31,sec)==1
            syn_wt(Str(:,1),Str(:,2))=max(smin,syn_wt(Str(:,1),Str(:,2))-0.1);        %this is where synaptic weights get reduced
        end;
        
        lastFired=fired;
    end;

    if (allInputs(31,sec)==1) && (output >= cutoff)
        Hits = Hits+1;
        cutoff=(cutoff+output+1)/2;
    elseif (allInputs(31,sec)==0) && (output < cutoff)
        Hits = Hits+1;
        cutoff=(cutoff+output-1)/2;
    end;   
end;

ErrorRate=(TotalInputs-Hits)/TotalInputs;

save('synaptic_connections.txt','post','-ascii','-tabs');
save('synaptic_weights.txt','syn_wt','-ascii','-double','-tabs');