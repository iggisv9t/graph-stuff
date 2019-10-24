import pandas as pd
import numpy as np
from tqdm import tqdm

def chunker(seq, size):
    """https://stackoverflow.com/a/434328"""
    return (seq[pos: pos + size] for pos in range(0, len(seq), size))

def make_conv(edges, feats, cols, by, on, size=1000000, agg_f='mean',
                      prefix='mean_'):
    """
    edges -- edgelist: pandas dataframe with two columns (arguments by and on)
    feats -- features dataframe with key column (argument on) 
             and features columns (argument cols)
    by -- column in edges to be used as source nodes
    on -- column in edges to be used as neighbor nodes
    size -- number of unique source nodes to be used in one chunk
    agg_f -- can be interpreted as pooling function. 
             Pandas has several optimised functions for basic statistics,
             that can be passed as string arg (see pandas docs),
             but you also can provide any function you like
    prefix -- prefix for new column names             
    """
    res_feats = [] # used to stack result chunks

    # get chunk of unique source nodes
    for chunk in tqdm(chunker(edges[by].unique(), size=size), 
                      total=(len(edges[by].unique()) // size) + 1):
        # for each chunk we get feature matrix for neighbours
        temp = edges[edges[by].isin(chunk)]\
                .merge(feats, on=on, how='left')
        # convolve and pool
        tempgb = temp[cols + [by, on]]\
                .groupby(by).agg({col: agg_f for col in cols}).reset_index()
        res_feats.append(tempgb.rename(columns={c: prefix + c for c in cols}))
    # concat results
    return pd.concat(res_feats, axis=0).reset_index(drop=True)
    