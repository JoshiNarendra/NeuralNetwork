function SpikingNN (epoch)
% Spiking network with STDP
% Created by Eugene M.Izhikevich.                February 3, 2004
% Modified to allow arbitrary delay distributions.  April 16,2008
% Modified to work with song files                December 7,2012 
%                                                --Narendra Joshi
M=20;       %number of synapses per neuron          
N1=30;      %neurons in layer 1          
N2=30;      %neurons in layer 2             
N=N1+N2;    % total number
syn_wt=[6*ones(N1,M);ones(N2,M)];         % synaptic weights

post=[];
for i=1:N1           % (1 to N1) is layer 1 and (N1+1 to N2) is layer 2
    p=N1+randperm(N1); %the array p contains list of possible post-synaptic neurons for the neuron at N(i), neurons from layer one form synapses only with neurons from layer 2
    post(i,:)=p(1:M);       % M synapses are formed by the excitatory neuron N(i) with the first M neurons in p (one synapse with each post-synaptic neuron)
end;
for i=N1+1:N
    post(i,1)= N+1;       %all neurons in second layer converge on one target- (N+1)th neuron, the last neuron
end;

save('synaptic_connections.txt','post','-ascii','-tabs');
save('synaptic_weights.txt','syn_wt','-ascii','-double','-tabs');

graph=zeros(epoch,2);
testDisplay=zeros(fix(epoch/5),2);

for t=1:epoch
    error=train;
    graph(t,:)=[t error];
    fprintf('Epoch %3.0f  Error rate is %.3f\n',t,error);
    if rem(t,5) == 0
        testError=test;
        testDisplay(fix(t/5),:)=[t testError];
        fprintf('Test error rate is %.3f\n',testError);
    end;
end;

figure(1);
plot(graph(:,1),graph(:,2));
xlabel('Epoch number');
ylabel('Error Rate');
title(sprintf('Error rate after training the Spiking NN for %.0f epochs',epoch));

figure(2);
plot(testDisplay(:,1),testDisplay(:,2));
xlabel('Epoch number');
ylabel('Test Error Rate');
title('Change in test error rate over the course of training');