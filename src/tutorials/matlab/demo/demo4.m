function L = demo4(I,color1, color2, T, lambda) 
    I = double(I);
    d1 = abs(I(:,:,1)-color1(1)) +  abs(I(:,:,2)-color1(2)) +  abs(I(:,:,3)-color1(3));
    d2 = abs(I(:,:,1)-color2(1)) +  abs(I(:,:,2)-color2(2)) +  abs(I(:,:,3)-color2(3));

    % parameter
    numVariablesN = size(I,1); % number of variables of first dimension
    numVariablesM = size(I,2); % number of variables of second dimension
    numLabels     = 3;      % number of labels for each variable


    numVariables = numVariablesN * numVariablesM;
 
    % binary function
    pottsFunction = openGMPottsFunction([numLabels, numLabels], 0, lambda);

    % create model
    gm = openGMModel;

    % add variables
    gm.addVariables(repmat(numLabels, 1, numVariables));

    % add unary functios and factor to each variable
    gm.addUnaries(0:numVariables-1, [d1(:)';d2(:)';T*ones(1,numVariables)]);  
 
    % add functions
    gm.addFunction(pottsFunction);

    % add binary factors to create grid structure
    % horizontal factors
    variablesH = 0 : (numVariables - 1);
    variablesH(numVariablesN : numVariablesN : numVariables) = [];
    variablesH = cat(1, variablesH, variablesH + 1);
    % vertical factors
    variablesV = 0 : (numVariables - (numVariablesN + 1));
    variablesV = cat(1, variablesV, variablesV + numVariablesN);
    % concatenate horizontal and vertical factors
    variables = cat(2, variablesH, variablesV);
    % add factors
    gm.addFactors(pottsFunction, variables);

    % print model informations
    disp('print model informations');
    opengm('modelinfo', 'm', gm);
    
    %infer
    disp('start inference');
    opengm('a','ALPHAEXPANSION', 'm', gm, 'o','out.h5');
    disp('load result');
    x = h5read('out.h5','/states');
    L = uint8(reshape(x,size(I,1),size(I,2))*120);
end