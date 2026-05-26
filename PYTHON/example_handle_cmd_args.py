#!/usr/bin/python
import getopt,json,os
from functions import crc32b
#
Version = "0.7331.1"
#
def HELP():
	global Options
	print("HELP....\n")
	for k in Options:
		o=Options[k]
		print("{} => {}".format( o['short'], o['name'] ))
#
def VERSION():
	global Version
	print("v{}".format(Version))
#
Options = {
	crc32b('-h'):{
		'name':'help',
		'short':'-h',
		'long':'--help',
		'accept':False, # accept value
		'value':False,
		'exec':HELP,
	},
	crc32b('-v'):{
		'name':'version',
		'short':'-v',
		'long':'--version',
		'accept':False, # accept value
		'value':False,
		'exec':VERSION,
	},
	crc32b('-f'):{
		'name':'file',
		'short':'-f',
		'long':'--file',
		'accept':True, # accept value
		'value':None,
	},
}
#
Stats = {
	'num_files':0, # num of files that was parsed
	'largest_line':-1,
	'shortest_line':-1,
}
#
def genShortArgs():
	global Options
	ret=""
	for k in Options:
		o = Options[k]
		if "accept" in o and o["accept"]:
			ret = "{}{}:".format(ret,o["short"][1:len(o["short"])])
		else:
			ret = "{}{}".format(ret,o["short"][1:len(o["short"])])
	return ret
#
def genLongArgs():
	global Options
	ret=[]
	for k in Options:
		o = Options[k]
		ret.append(o['long'])
	return ret
#--
#
def main(argv):
	global Options, Stats
	#
	try:
		opts, args = getopt.getopt(argv,genShortArgs(),genLongArgs())
	except getopt.GetoptError:
		opt_help = True
	#
	for opt, arg in opts:
		if crc32b(opt) in Options:
			o = Options[crc32b(opt)]
			if 'accept' in o and o['accept']:
				Options[crc32b(opt)]['value'] = arg
			elif "exec" in o:
				o['exec']()
				sys.exit(1)
			else:
				Options[crc32b(opt)]['value'] = True
	#--
	# RUN your CODE here!
	#--
	#
	print("Stats: ")
	print(Stats)

#--
if __name__ == "__main__":
	main(sys.argv[1:])
