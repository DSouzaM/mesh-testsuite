import pandas as pd
import numpy as np
import sys

from matplotlib import pyplot
import math

df = pd.read_csv(sys.argv[1]) 

print(df.head()) 
print('-'*30)


print("dTLB-load-misses statistics")
stats = df.groupby(['memlib'])['dTLB-load-misses'].agg(['mean', 'count', 'std'])

ci95_hi = []
ci95_lo = []

for i in stats.index:
    m, c, s = stats.loc[i]
    ci95_hi.append(m + 1.96*s/math.sqrt(c))
    ci95_lo.append(m - 1.96*s/math.sqrt(c))

stats['ci95_hi'] = ci95_hi
stats['ci95_lo'] = ci95_lo
print(stats)

x_values = stats.index.tolist()

yaxis_points = []
yaxis_legend = []

for i in range(len(x_values)):
	yaxis_points.append(2*i +1)
	yaxis_legend.append(x_values[i])


print(yaxis_legend)
print(yaxis_points)

pyplot.figure()
pyplot.title("dTLB-load-misses")
mean_data = stats.loc[[(x) for x in x_values],'mean'].tolist()
ci95_hi_data= stats.loc[[x for x in x_values],'ci95_hi'].tolist()
ci95_lo_data= stats.loc[[x for x in x_values],'ci95_lo'].tolist()
error_data= [x1 - x2 for (x1, x2) in zip(ci95_hi_data, ci95_lo_data)]
pyplot.errorbar(mean_data,yaxis_points,xerr=error_data, fmt = 'o', color = 'k')
yaxis_points.append(yaxis_points[len(yaxis_points)-1] +1)
yaxis_points.insert(0, 0)

yaxis_legend.insert(len(yaxis_legend), '')
yaxis_legend.insert(0,'')

pyplot.yticks(yaxis_points, yaxis_legend) 
pyplot.savefig(f'{sys.argv[1]}-dTLB.png')


print('-'*30)
print("iTLB-load-misses statistics")
stats = df.groupby(['memlib'])['iTLB-load-misses'].agg(['mean', 'count', 'std'])


print(yaxis_legend)
print(yaxis_points)



ci95_hi = []
ci95_lo = []

for i in stats.index:
    m, c, s = stats.loc[i]
    ci95_hi.append(m + 1.96*s/math.sqrt(c))
    ci95_lo.append(m - 1.96*s/math.sqrt(c))

stats['ci95_hi'] = ci95_hi
stats['ci95_lo'] = ci95_lo
print(stats)

x_values = stats.index.tolist()

yaxis_points = []
yaxis_legend = []

for i in range(len(x_values)):
	yaxis_points.append(2*i +1)
	yaxis_legend.append(x_values[i])

# x_values = df.index.levels[0]
pyplot.figure()
pyplot.title("iTLB-load-misses")
mean_data = stats.loc[[(x) for x in x_values],'mean'].tolist()
ci95_hi_data= stats.loc[[x for x in x_values],'ci95_hi'].tolist()
ci95_lo_data= stats.loc[[x for x in x_values],'ci95_lo'].tolist()
error_data= [x1 - x2 for (x1, x2) in zip(ci95_hi_data, ci95_lo_data)]
pyplot.errorbar(mean_data,yaxis_points,xerr=error_data, fmt = 'o', color = 'k')
yaxis_points.append(yaxis_points[len(yaxis_points)-1] +1)
yaxis_points.insert(0, 0)

yaxis_legend.insert(len(yaxis_legend), '')
yaxis_legend.insert(0,'')

pyplot.yticks(yaxis_points, yaxis_legend) 
pyplot.savefig(f'{sys.argv[1]}-iTLB.png')
