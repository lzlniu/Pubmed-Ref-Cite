import sys
import pandas as pd
import numpy as np
pd.options.mode.chained_assignment = None  # default='warn'

pmid_year = pd.read_csv(sys.argv[1], sep='\t', header=None) #sorted.tmp
citations = pd.read_csv(sys.argv[2], sep='\t', header=None) #sorted_all_citation_counts.tsv
pmid_year = pmid_year.dropna()
pmid_year[0] = pmid_year[0].astype(int) #pmid
pmid_year[1] = pmid_year[1].astype(int) #year
citations[0] = citations[0].astype(int) #pmid
citations[1] = citations[1].astype(float) #citation_counts
merged = pmid_year[[0,1]].merge(citations, on=0, how='left').fillna(0)

new_merged = pd.DataFrame()
print("start!")
#print(new_merged)
for year in pmid_year[1].unique():
	year_article = merged.loc[merged['1_x'] == year]
	year_mean = year_article['1_y'].mean()
	#year_median = year_article['1_y'].median()
	print(year, year_mean)
	if year_mean > 0:
		year_article['1_y'] = year_article['1_y']/year_mean
		#year_article['1_y'] = np.log(1+year_article['1_y']/year_mean)
	else:
		year_article['1_y'] = 0
	new_merged = pd.concat([new_merged, year_article])
	#print("done!")
	#print(new_merged)
	#if year_median>0:
	#	for pmid in year_article[0]:
	#		merged['1_y'].loc[merged[0] == pmid] = year_article['1_y'].div(year_median, axis=0)
	#for pmid in year_article[0]:
		#print(year_article['1_y'][year_article[0] == pmid]/year_median)
		#print(pmid, float(year_article['1_y'].loc[year_article[0] == pmid]/year_median))
print("done!")
new_merged[[0,'1_y']].to_csv(sys.argv[3], sep='\t', header=False, index=False) #normalized_citation_counts.tsv

