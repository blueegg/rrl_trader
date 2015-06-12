function returns = read_data(path, filename, sheet)
%path = '/Users/deepakmenghani/Dropbox/RRL Trader Project/Data/';
%filename = 'USDINR.xls';
%sheet = '15 min';
data = xlsread(strcat(path , filename),sheet);
price = data(:,5);
price= [price circshift(price,1)];
n= length(price);
returns = (price(2:n,1)./price(2:n,2))-1;
clear price,data,n
return