#!/usr/bin/python
#
# statlog.py -> Generate reports from log files.
#--
import getopt,json,os,datetime
from functions import *
#
Version = "0.7331.1"
VersionName = "StatLog"

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
	print("{} v{}".format(VersionName,Version))

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
		'name':'fileName',
		'short':'-f',
		'long':'--file_name',
		'accept':True, # accept value
		'value':"",
	},
}

# Stats
S = {
	#'ip_crc':{
	#	'ip':'',    # ip string
	#	'cnt':'',   # count ip repeat
	#	'codes':[], # used http codes
	#}
}
ALL=0
#
def Run():
	global S,ALL
	print("Run() START! on file: {}".format( Options[crc32b('-f')]['value'] ))
	cnt=0
	with open( Options[crc32b('-f')]['value'] ) as tf:
		for line in tf:
			#
			line  = line.strip()
			#print("DEBUG line: {}".format(line))
			#        0                      1                                2                        3
			# ['192.168.1.35', '[14/Apr/2025:22:11:09 +0000]', '"GET / HTTP/1.0" 200 13 "-"', '"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36"']
			#a = pmatch(line,"([0-9\.]+)+\x20+(.*)+\x20(.*)+\x20+(\[.*\])\x20(\".*\")\x20(.*)")
			# ['192.168.1.35', '-', '-', '14/Apr/2025:22:11:09 +0000', '"GET / HTTP/1.0" 200 13 "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36"']
			a = pmatch(line,"([0-9\.]+)\x20([a-zA-Z0-9\-]+)\x20([a-zA-Z0-9\-]+)\x20\[+([0-9A-Za-z\/\:\x20\+]+)+\]\x20+(.*)")
			#print(a)
			#
			ip       = a[0]
			crc      = crc32b(ip) # get ip crc32b
			unkn     = a[1]
			user     = a[2]
			feca     = a[3]
			# convert date into timestamp
			date_obj = datetime.datetime.strptime(feca, "%d/%b/%Y:%H:%M:%S %z")
			ts       = date_obj.timestamp()
			cnt_user = 0
			cnt_unkn = 0
			if user!='-':
				cnt_user = 1
			if unkn!='-':
				cnt_unkn = 1
			#
			a = pmatch(a[4],"\"(.*)\"+\x20+([\d+]+)+\x20([\d+]+)+\x20+\"(.*)\"")
			#
			if crc in S:
				#
				S[crc]['cnt']+=1
				S[crc]['cnt_user']+=cnt_user
				S[crc]['cnt_unkn']+=cnt_unkn
				#
				if S[crc]['fts']<int(ts) and S[crc]['lts']<int(ts):
					S[crc]['lts'] = int(ts)
					S[crc]['ldt'] = feca
				elif S[crc]['fts']>int(ts):
					S[crc]['fts'] = int(ts)
					S[crc]['fdt'] = feca
				#
				if a[1] not in S[crc]['codes']:
					S[crc]['codes'][a[1]] = 1
				else:
					S[crc]['codes'][a[1]] += 1
			else:
				S[crc] = {
					'ip'      :ip,
					'cnt'     :1,
					'cnt_user':cnt_user,
					'cnt_unkn':cnt_unkn,
					'codes'   :{},
					'fdt'     :feca,
					'ldt'     :'',
					'fts'     :int(ts),
					'lts'     :0,
				}
				S[crc]['codes'][a[1]] = 1
			ALL+=1
	print("Stats....( {} ): ".format(ALL))
	#print(S)
	cnt=0
	for k in S:
		o = S[k]
		print("{}.) {}|{} {}, codes: {} fdt: {}, ldt: {}".format( cnt, o['cnt'], o['cnt_user'], o['ip'], o['codes'], o['fdt'], o['ldt'] ))
		cnt+=1
#
def Main(argv):
	global Options
	#
	opt_help=False
	#
	try:
		opts, args = getopt.getopt(argv,genShortArgs(Options),genLongArgs(Options))
		#
		for opt, arg in opts:
			if crc32b(opt) in Options:
				o = Options[crc32b(opt)]
				if 'accept' in o and o['accept']:
					if type(Options[crc32b(opt)]['value']).__name__ == "int":
						Options[crc32b(opt)]['value'] = int(arg)
					else:
						Options[crc32b(opt)]['value'] = arg
				elif "exec" in o:
					o['exec']()
					sys.exit(1)
				else:
					Options[crc32b(opt)]['value'] = True
	except getopt.GetoptError:
		opt_help = True
	if opt_help:
		print("HElp!")
		Options[crc32b('-h')]['exec']()
		sys.exit(1)
	print(Options)
	#...
	if Options[crc32b('-f')]['value']=="":
		print("Required -f to define file where to read from...")
		sys.exit(1)
	#
	Run()

#
if __name__ == "__main__":
	Main(sys.argv[1:])

