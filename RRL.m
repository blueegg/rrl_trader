clear all;
path = '/Users/deepakmenghani/Dropbox/RRL Trader Project/Data/';
filename = 'USDINR.xls';
sheet = '30 min';
data_returns = read_data(path,filename, sheet);

%Scalng the returns to 100 times 

data_returns = 100 *data_returns;

%Normalizing to mean 0 and variance 1
data_mean = mean(data_returns);
data_std = std(data_returns);
data_returns = (data_returns - data_mean)./data_std;

%Set Parameters
m = 10;%No of lookback 
w = 100*rand(m+1,1);%convention [Ft-1, r1,...,rm,1] 
%w(m+2) = 0;
A = 0;B=0;old_A = 0;old_B = 0;

%Read the returns from
T= 2000;%length(data_returns);
Ft=0;
Ft1=0;
delta = 0.00;%transaction costs
eta = 0.01;%Time Window
mu = 20 ; %notional 

rho = 100;  % learning rate  
%rt is the return between t-1 and t. Ft is the action taken at time t
%Run Loop - Minin
Ft1 = 0;    % initial action is zero
RtVector = zeros(m-1,1) ; % vector to store Rt
DFDwVector = zeros(m-1,m+1) ; % vector to store DFDw;
FtVector = zeros(m-1,1) ; % vector to store Ft 
StVector = zeros(m-1,1);
cumRt = zeros(m-1,1);

for i = m:T
    %Take new action and get consequences
    x = [Ft1; data_returns((i-m+1):i)];
    Ft = tanh(w'*x);                        % write a seperate function for Ft
    FtVector = [FtVector; Ft];   % update Ft Vector
  
    Rt = mu*Ft1*data_returns(i) - mu*delta*abs(Ft-Ft1);
    RtVector = [RtVector; Rt];
    
    
    %Calculate Gradient
    A = ((i-1)*A+Rt)/i;
    B = ((i-1)*B+Rt^2)/i;   
    
    % Update the derivative of sharpe ratio 
    DSDA = 0;
    DSDB = 0;
    
    if B > A^2
        DSDA = (B-A^2)^(-0.5) + A^2*(B-A^2)^(-1.5);
        DSDB = -0.5*A*(B-A^2)^(-1.5);
    end
    DADRt = 1/i ;
    DSDw = zeros(m+1,1);
    
    for t = 1:i
        if t >1
            DRDFt = -mu*delta*sign(FtVector(t) - FtVector(t-1));
            DRDFt1 = mu* data_returns(t)+mu*delta*sign(FtVector(t) - FtVector(t-1));
            DFtDw = (1- FtVector(t)^2)*(x + w(1)*DFDwVector(t-1,:)');
            DFt1Dw = DFDwVector(t-1,:)';
        else
            DRDFt = -mu*delta*sign(FtVector(t));
            DRDFt1 = mu* data_returns(t)+mu*delta*sign(FtVector(t));
            DFtDw = (1- FtVector(t)^2)*(x);
            DFt1Dw = zeros(m+1,1);
        end
            
        DBDRt = RtVector(t)/i;
        DSDw = DSDw + (DSDA *DADRt + DSDB *DBDRt)*(DRDFt*DFtDw +DRDFt1*DFt1Dw);                        % derivative
    end
    % update w to calulate 
        w = w + rho * DSDw
        disp(Ft);
    
        %Update Parameter     %Update next step variables
    
    Ft1 = Ft;
    cumRt = [cumRt; cumRt(i-1)+(Rt/mu)];
    DFDwVector = [ DFDwVector ; DFtDw'] ; % vector to store DFDw;
    St = 0;
    if(B>A^2) 
           St = A/sqrt(B-A^2);
    end
    StVector  = [StVector; St];
end

%Plot St , Cummulative Returs
plot(StVector); 
% hold on;
% plot(cumRt);
% hold off;
