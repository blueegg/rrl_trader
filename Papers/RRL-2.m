%Set Parameters
m = 10;%No of lookback 
w = rand(m+2,1);%convextion [Ft-1, r1,...,rm,1]
A = 0;B=0;old_A = 0;old_B = 0;  

%Read the returns from
data_returns = mvnrnd(0,0.10,1000);

%Normalizing to mean 0 and variance 1
data_mean = mean(data_returns);
data_std = std(data_returns);
data_returns = (data_returns - data_mean)./data_std;

T= length(data_returns);
Ft=0;
Ft1=0;
delta = 0.000;%transaction costs
eta = 0.01;%Time Window
mu = 20 ; %notional 

rho = 0.01;  % learning rate  
%rt is the return between t-1 and t. Ft is the action taken at time t
%Run Loop - Minin
Ft1 = 0;    % initial action is zero
RtVector = [] ; % vector to store Rt
DFDwVector = [] ; % vector to store DFDw;
FtVector = [] ; % vector to store Ft 
for i = m:T
    %Take new action and get consequences
    x = [Ft1; data_returns((i-m+1):i);1];
    Ft = tanh(w'*x);                        % write a seperate function for Ft
    Rt = mu*(Ft1*data_returns(i) - delta*abs(Ft-Ft1));
    %Calculate Gradient
    A = ((i-1)*A+p_return)/i;
    B = ((i-1)*B+p_return^2)/i;   
    delta_A = A - old_A;
    delta_B = B - old_B;
    % Update the derivative of sharpe ratio 
    
    DSDA = (B-A^2)^(-0.5) + A^2*(B_A^2)^(-1.5);
    DSDB = -0.5*A*(B-A^2)^(-1.5);
    DADRt = 1/i ;
    
    DSDw = zeros();
    for t = 1:i
        if t >1
            DRDFt = -mu*delta*sign(FtVector(t) - FtVector(t-1));
            DRDFt1 = mu* data_returns(i)+mu*delta*sign(FtVector(t) - FtVector(t-1));
            DFtDw = (1- FtVector(i)^2)*(x + w(m+2)*DFtDwVector(t-1,:)');
        else
            DRDFt = -mu*delta*sign(FtVector(t));
            DRDFt1 = mu* data_returns(i)+mu*delta*sign(FtVector(t));
            DFtDw = (1- FtVector(i)^2)*(x);
        end
        
        DBDRt = RtVector(t)/i;
        DSDw = DSDw + (DSDA *DADRt + DSDB *DBDRt)*(DRDFt*DFtDw +DRDFt1*DFt1Dw);                        % derivative
    end
    % update w to calulate 
        w = w + rho * DSDw ; 
    %Update Parameter     %Update next step variables
    old_A = A;
    olb_b = B;
    Ft1 = Ft;
    RtVector = [RtVector; Rt];
    FtVector = [FtVector, Ft];
    DFDwVector = [ DFDwVector ; DFDtw] ; % vector to store DFDw;
    
end