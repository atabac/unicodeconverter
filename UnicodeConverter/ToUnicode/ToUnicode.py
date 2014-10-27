import sys, os, fnmatch, subprocess, filecmp

def findFiles (path, *filters):		
	for root, dirs, files in os.walk(path):
		for filter in filters:
			for file in fnmatch.filter(files, filter):
				yield os.path.join(root, file)

def cleanup(file):
	if os.path.exists(outFile):
		os.remove(outFile)
		
param1 = sys.argv[1]				
			
if (os.path.isdir(param1)):
			for textFile in findFiles(param1, '*.h', '*.cpp'):
				if not ( textFile.endswith("stdafx.cpp") or
						 textFile.endswith("stdafx.h") or 
						 textFile.endswith("Resource.h") or 
						 textFile.endswith("targetver.h")):
					print("[analyzing] " + os.path.basename(textFile))
					fileName = os.path.basename(textFile) 
					outFile = fileName.split(".")[0] + "Mod." + fileName.split(".")[1];
					#print("new name: " + outFile)

					#cleanup first
					cleanup(outFile)
						
					subprocess.call( ["UnicodeConverter.exe", textFile, outFile])
					
					if os.path.exists(outFile):
							if os.path.exists(textFile):
								if not filecmp.cmp(textFile,outFile, shallow=False):
									print("[modifying] " + textFile)
									os.remove(textFile)
									os.rename(outFile, textFile)
					
					#cleanup first
					cleanup(outFile)

else:
	print(param1 + " is expected to be a directory")

	
