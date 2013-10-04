% MC-b by Miao Fan 
% Tsinghua University
% fanmiao.cslt.thu@gmail.com

function Out = MC_b(Xtrain, Ytrain, Xtest, Ytest)

    [numOfXtrain, demXtrain] = size(Xtrain);
    [numOfYtrain, demYtrain] = size(Ytrain);

    B = zeros(1, demYtrain);

    X = [Xtrain; Xtest];
    [x, y] = find(X > 0);
    OmigaX = [x, y];
    [r, c] = size(OmigaX);
    numOfOmigaX = r;

    Y = [Ytrain; zeros(size(Ytest))];
    [x, y] = find(Y > 0);
    OmigaY = [x, y];
    [r, c] = size(OmigaY);
    numOfOmigaY = r;

    Z = [X, Y];

    params = getParams();
    muf = params.mu;

    for i = 1 : params.maxitr
        Zp = Z;
        gb = getGB(params.lamda, numOfOmigaY, OmigaY, X, Y, Z, B);
        B = B - params.taub * gb;
        gz = getGZ(params.lamda, numOfOmigaY, numOfOmigaX, OmigaY, OmigaX, Y, X, Z, B);
        A = Z - params.tauz * gz;

        [U, S, V] = svd(A);

        S = max(0,S-params.tauz * muf);
        Z = U * S * V';
        if (norm(Zp-Z, 'fro') <= params.tol)
            Out.Z = Z;
            Out.B = B;
            return;
        end
    end
    
    Out.Z = Z;
    Out.B = B;
    
    
end

    %
    % inner gradient function for Z (MC_b)
    %

function gz = getGZ(lamda, numOfOmigaY, numOfOmigaX, OmigaY, OmigaX, Y, X, Z, B)

    [rowZ, columnZ] = size(Z);
    [rowX, columnX] = size(X);

    gz = zeros(rowZ, columnZ);

    for k = 1 : numOfOmigaY
        i = OmigaY(k, 1);
        j = OmigaY(k, 2);
        gz(i, j + columnX) = lamda / numOfOmigaY * (-Y(i, j) / (1 + exp(Y(i, j) * (Z(i, j + columnX) + B(1, j)))));        
    end

    for k = 1 : numOfOmigaX      
        i = OmigaX(k, 1);
        j = OmigaX(k, 2);
         gz(i, j) = 1.0 / numOfOmigaX * (Z(i, j) - X(i, j));
    end
end

        
    %
    % inner gradient function for B
    %
    
function gb = getGB(lamda, numOfOmigaY, OmigaY, X, Y, Z, B)

    [rowB, columnB] = size(B);
    [rowY, columnY] = size(Y);
    [rowX, columnX] = size(X);
    
    gb = zeros(rowB, columnB);
    gy = zeros(rowY, columnY);
    
    for k = 1 : numOfOmigaY
        i = OmigaY(k, 1);
        j = OmigaY(k, 2);
        gy(i, j) = lamda / numOfOmigaY * (-Y(i, j)/ (1 + exp(Y(i, j) * (Z(i, j + columnX) + B(rowB, j)))));
    end
    
    for j = 1 : columnY
        sum = 0.0;
        for i = 1 : rowY
            sum = sum + gy(i, j);
        end
        gb(rowB, j) = sum;
    end   
end
    



