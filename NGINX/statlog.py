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
S_TS  = 0 # start timestamp
E_TS  = 0 # end timestamp
ALL   = 0
REFES = {} # refecrc=refe
USERA = {} # useracrc=usera
REQS  = {} # sreqcrc=sreq
#
def Run():
	global S,ALL,USERA,REFES,S_TS,E_TS,REQS
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
			#
			if S_TS==0 or S_TS>ts:
				S_TS=ts
			if E_TS==0 or E_TS<ts:
				E_TS=ts
			cnt_user = 0
			cnt_unkn = 0
			if user!='-':
				cnt_user = 1
			if unkn!='-':
				cnt_unkn = 1
			#--
			# scrap request, response code, response size
			a = pmatch(a[4],"\"(.*)\"+\x20+([\d+]+)+\x20([\d+]+)+\x20+\"(.*)\"")
			# ['GET /favicon.ico HTTP/1.0', '200', '4606', 'https://grandekos.com/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0']
			ureq = a[0]  # GET / HTTP/1.0
			code = a[1]  # HTTP code ex.: 200, 404, 305, 500...
			size = a[2]  # response length of data
			tmp  = a[3]  # continue parse
			#--
			# scrap ureq. Res: ['GET','/path_we_search']
			a = pmatch(ureq,"(GET|POST|HEAD|OPTIONS|PROPFIND|[A-Z])\x20(.*)\x20HTTP.\d.\d")
			nreq = a[0] # GET | POST
			sreq = a[1] # /path_we_search
			sreqcrc = crc32b(sreq)
			#--
			# scrap referer and userAgent
			a = pmatch(tmp,"([\-]|.*)\"\x20\"(.*)")
			refe           = a[0]
			refecrc        = crc32b(refe)
			usera          = a[1]
			useracrc       = crc32b(usera)
			cnt_refe       = 0
			cnt_empty_refe = 0
			#
			if refe!='-':
				cnt_refe=1
			else:
				cnt_empty_refe=1
			#--
			# Old IP
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
				if code not in S[crc]['codes']:
					S[crc]['codes'][code] = 1
				else:
					S[crc]['codes'][code] += 1
				#
				if useracrc not in S[crc]['usera']:
					S[crc]['usera'][useracrc] = 1
					USERA[useracrc] = usera
				else:
					S[crc]['usera'][useracrc] += 1
				# referer
				if refecrc not in S[crc]['refes']:
					S[crc]['refes'][refecrc] = 1
					REFES[refecrc] = refe
				else:
					S[crc]['refes'][refecrc] += 1
				# nreq => GET | POST
				if nreq not in S[crc]['nreq']:
					S[crc]['nreq'][nreq] = 1
				else:
					S[crc]['nreq'][nreq] += 1
				# sreq => /path_we_search
				if sreqcrc not in S[crc]['sreq']:
					S[crc]['sreq'][sreqcrc] = 1
					REQS[sreqcrc] = sreq
				else:
					S[crc]['sreq'][sreqcrc] += 1
			# New IP
			else:
				S[crc] = {
					'ip'      :ip,
					'cnt'     :1,
					'cnt_user':cnt_user,
					'cnt_unkn':cnt_unkn,
					'cnt_empty_refe':cnt_empty_refe,
					'cnt_refe':cnt_refe,
					'nreq'    :{nreq:1},
					'sreq'    :{sreqcrc:1},
					'refes'   :{refecrc:1},  # lets save refers like codes
					'codes'   :{code:1},     # count unique
					'usera'   :{useracrc:1}, #
					'fdt'     :feca,
					'ldt'     :'',
					'fts'     :int(ts),
					'lts'     :0,
				}
				REFES[refecrc]  = refe
				USERA[useracrc] = usera
			ALL+=1
	print("Stats... DONE.( All: {} | Refs: {} | UA: {} ): ".format( ALL,len(REFES),len(USERA) ))
	#print(S)
	cnt=0
	for k in S:
		o = S[k]
		#if len(o['nreq'])>1:
		print("{}.) ( {}|us:{}|rf:{}|er:{}|un:{} ) {}, codes: {} fdt: {}, ldt: {}, usera: {}, refes: {}, nreq: {}, sreq: {}".format( cnt, o['cnt'], o['cnt_user'],o['cnt_refe'],o['cnt_empty_refe'],o['cnt_unkn'], o['ip'], o['codes'], o['fdt'], o['ldt'], len(o['usera']), len(o['refes']), len(o['nreq']), len(o['sreq']) ))
		cnt+=1
	#
	#for refe in REFES:
	#	print("{}".format(REFES[refe]),end=', ')
	#
	#for usera in USERA:
	#	print("{}".format(USERA[usera]),end=', ')
	print("Stats... DONE.( All: {} | Refs: {} | UA: {} ): ".format( ALL,len(REFES),len(USERA) ))

#
def Save():
	global S,ALL,USERA,REFES,S_TS,E_TS
	print("Save() START, S.len: {}, ALL: {}".format( len(S), ALL ))
	# Ex. of S row: 
	# 51.) 25|0|0|1 66.249.75.197, codes: {'200': 24, '404': 1} fdt: 02/Jun/2025:16:37:19 +0000, ldt: 04/Jun/2025:05:24:43 +0000, usera: {'37b3aaac': 7, '5f5c5f93': 17, 'ddb1781b': 1}, refes: {'97ddb3f8': 8, 'f6bdb1dd': 3, 'ac749338': 6, 'a6d76f77': 3, '17d2ffe5': 1, '671ce8e5': 2, '7eef89ed': 1, 'b21d881c': 1}
	# S     is object or dict. Ex. row: 'ipCrc32b' : ipdata_unique
	# USERA is object or dict. Ex. row: 'uaCrc32b' : userAgent_unique
	# REFES is object or dict. Ex. row: 'rfCrc32b' : reference_unique
	fnh       = crc32b( Options[crc32b('-f')]['value'] )
	fn_ipdata = "ipdata_{}_{}_{}.dbk".format(fnh, round(S_TS),round(E_TS))
	fn_usera  = "usera_{}_{}_{}.dbk".format(fnh, round(S_TS),round(E_TS))
	fn_refer  = "refer_{}_{}_{}.dbk".format(fnh, round(S_TS),round(E_TS))
	print("using fn: {}".format( fn_ipdata ))

#
def Load():
	global S,ALL,USERA,REFES
	print("Load() START")

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
	Save()

#
if __name__ == "__main__":
	Main(sys.argv[1:])

