N-Layer Neural Network matricial implementation in NetLogo 6 by Fernando Sancho (based on a work of Stephen Larroque)
 
## Main Procedures

`ANN:Train` -- Main procedure to train Neural Network

     Input: [MiniBatch Ws Architecture lambda Xtrain Ytrain Xtest Ytest  epsilon nIterMax debug?]
           MiniBatch     : Size of minibatch to be used in every epoch 
           Ws            : Initial Weight matrices (depends on Architecture)
           Architecture  : Architecture of Network [N1 ... Nn]
           lambda        : Regularization factor (0)
           Xtrain        : Matrix with input data for Train Data
           Ytrain        : Matrix with output data for Train Data
           Xtest         : Matrix with input data for Test Data
           Ytest         : Matrix with output data for Test Data
           epsilon       : Learning rate for Back-propagation step
           nIterMax      : Number of epochs for training loop
           debug?        : Print info while training
     Output: [Ws errtrain errtest]
           Ws            : Weight Matrices after training
           errtrain      : List of errors on train data
           errtest       : List of errors on test data

`ANN:ForwardProp` -- Evaluation/Forward Propagation of a Neural Network

     Input: [Ws X]
           Ws           : Weight Matrices
           X            : Input data matrix to compute
     Output: [O As Zs]
           O            : Output data matrix
           As           : List of matrix activations in every layer
           Zs           : List of matrix 

`ANN:ComputeError` -- Compute error from outputs

     Input: [Y O Ws lambda]
           Y            : Real/expected output data matrix
           O            : Output data matrix from the network
           Ws           : Weights of the network
           lambda       : Regularization factor
     Output: [err]
           err          : mean error (number) of O from Y
