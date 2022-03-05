import sys
import numpy as np
import pandas as pd

print("input file:", sys.argv[1])
print("output file:", sys.argv[2])
citations = pd.read_csv(sys.argv[1], sep='\t', header=None)
alpha=float(sys.argv[3])
print("alpha:", alpha)
pd.concat([citations[0], 1+np.log(alpha+citations[1])], axis=1, join="inner").to_csv(sys.argv[2], sep='\t', header=False, index=False)
print("successfully saved the output file")

