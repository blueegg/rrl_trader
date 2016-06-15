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

    data_ret = data_return * 100
    data_mean = data_return.mean()
    data_std = data_return.std()
    data_return = (data_return - data_mean) / data_std

    print(np.mean(data_return), np.std(data_return))

    fig = plt.subplots(figsize=(10, 6))
    plt.plot(close_price, '-b', label = "close price")

    plt.figure(num = 2, figsize=(10, 6))
    plt.plot(data_return, '-b', label = "returns")

    plt.show()
