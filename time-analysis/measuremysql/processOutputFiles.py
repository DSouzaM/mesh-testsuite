fileNamesList= ['output-mysql-ycsb-malloc.txt','output-mysql-ycsb-jemalloc.txt','output-mysql-ycsb-mesh.txt']
outputFileName = 'outputFile.csv'
outputFile = open(outputFileName,'a+')
outputFile.write("read time, read count, update time, update count, insert time, insert count, allocator\n")
        

def parseAndOutput(fString):
	f = open(fString, 'r')
	insertTimes = []
	readTimes = []
	updateTimes = []
	lines = f.readlines()
	cursor = 0
	while(cursor < len(lines)):
		line = lines[cursor]
		while(not line.startswith('Run finished') and cursor + 1 < len(lines)):
			cursor += 1
			line = lines[cursor]

		if(cursor + 1 == len(lines)):
			break;
		line = lines[cursor+1]
		if(line.startswith('INSERT')):
			splits = line.split(',')
			time = (splits[0].split(':')[1].strip())
			count = int(splits[1].split(':')[1].strip())
			insertTimes.append((time,count))

		if(line.startswith('READ')):
			splits = line.split(',')
			time = (splits[0].split(':')[1].strip())
			count = int(splits[1].split(':')[1].strip())
			readTimes.append((time,count))

		line = lines[cursor+2]
		if(line.startswith('UPDATE')):
			splits = line.split(',')
			time = (splits[0].split(':')[1].strip())
			count = int(splits[1].split(':')[1].strip())
			updateTimes.append((time,count))


		cursor += 1

	for i in range(0,len(readTimes)):
		outputFile.write(",".join([readTimes[i][0],str(readTimes[i][1]),updateTimes[i][0],str(updateTimes[i][1]),insertTimes[i][0],str(insertTimes[i][1]),fString.split('-')[-1].split('.')[0]]))
		outputFile.write('\n')

for fString in fileNamesList:
	parseAndOutput(fString)

outputFile.close()
