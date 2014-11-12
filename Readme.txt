To create and train the spiking neural network, simply type in

>> SpikingNN(number_of_epochs);

from within the directory where this script is. For good results, use number_of_epochs = 150.

once the training is complete, you will see two graphs of error rates, one for training data and the other for test data.

The network tests itself after every 5 epochs of training. But if you would like to test it again, you can simply type:

>>test



***********************


The training sets and test sets have already been provided. They are automatically loaded into the neural network by the respective scripts for training and testing. 

If you would like to generate your own auditory inputs, please use the scripts in the included folder named "auditory features"
Detailed instructions for how to run the those  scripts are provided as comments inside the script named "songgeatures.m"