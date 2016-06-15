#!/usr/bin/env python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def Read_data(name, sheet):
    xl = pd.ExcelFile(name)
    df = xl.parse(sheet)

    # replace zero by bfill
    df['Close'].replace(to_replace=0.0, method='bfill', inplace=True)

    Close = np.array(df['Close'])
    Close = np.flipud(Close)

    return Close

if __name__ == "__main__":
    close_price = Read_data("Data/USDINR.xls", "30 min")
    data_return = close_price[1:] / close_price[:-1] - 1

    data_return = data_return * 100
    data_mean = data_return.mean()
    data_std = data_return.std()
    data_return = (data_return - data_mean) / data_std

    print(np.mean(data_return), np.std(data_return))

    m = 10	#No of lookback 
    w = np.random.rand(m + 1) * 100	# convention [Ft-1, r1,...,rm,1]

    A = 0
    B = 0
    old_A = 0
    old_B = 0

    T = 2000        #length of data_return
    Ft = 0
    Ft1 = 0;
    delta = 0.00	#transaction costs
    eta = 0.01	    #Time Window
    mu = 20	        #notional 

    rho = 100	    #learning rate  
    #rt is the return between t-1 and t. Ft is the action taken at time t
    #Run Loop - Minin
    Ft1 = 0	        #initial action is zero
    RtVector = zeros(m-1,1)	#vector to store Rt
    DFDwVector = zeros(m-1,m+1) ; % vector to store DFDw;
    FtVector = zeros(m-1,1) ; % vector to store Ft 
    StVector = zeros(m-1,1);
    cumRt = zeros(m-1,1);

    fig = plt.subplots(figsize=(10, 6))
    plt.plot(close_price, '-b', label = "close price")

    plt.figure(num = 2, figsize=(10, 6))
    plt.plot(data_return, '-b', label = "returns")

    plt.show()
