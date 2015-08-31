import sys

def malletlda2kert(malletldafile, networkfile, dictfile):
	f = open(malletldafile,'r')
	fdict = open(dictfile, 'w')
	fnet = open(networkfile, 'w')
	lastid = -1	
	lines = f.readlines()
	for l in lines[3:]:
		token = l.rstrip().split()
		id = int(token[3])
		if id>lastid:
			fdict.write('\t'.join((str(id+1),token[4]))+'\n')
			lastid = id
		did = int(token[0])
		tid = int(token[-1])
		fnet.write('{0} {1} {2}\n'.format(did+1,id+1,tid+1))
	f.close()
	fnet.close()
	fdict.close()

def malletlda2tt(malletldafile, assignfile, dictfile, corpusfile):
	f = open(malletldafile,'r')
	fdict = open(dictfile, 'w')
	fassign = open(assignfile, 'w')
	fcorpus = open(corpusfile, 'w')
	lastid = -1
	lastdid = 0
	lines = f.readlines()
	vocab = {}
	for l in lines[3:]:
		token = l.rstrip().split()
		id = int(token[3])
		if not vocab.has_key(id): 
			vocab[id] = token[4]
			if id>lastid:
				 lastid = id
		did = int(token[0])
		tid = int(token[-1])
		if did>lastdid:
			lastdid = did
			fassign.write('\n0')
			fcorpus.write('\n'+token[4])
		else:
			fcorpus.write(' '+token[4])
		fassign.write(' {0}:{1}'.format(id,tid))

	f.close()
	fassign.close()

	for id in range(lastid+1):
		fdict.write(vocab[id]+'\n')
	fdict.close()


if __name__ == '__main__':
	locals()["malletlda2{0}".format(sys.argv[1])](*sys.argv[2:])