from os import path, walk
import os, time

f = []
for (dirpath, dirnames, filenames) in walk('js/'):
    f.extend(filenames)
    
comp = False
for filename in f:
  if filename.endswith('.coffee') and time.time() - path.getmtime('js/' + filename[:-7] + '.js') > 4:
    comp = True

if comp:
  print 'compiling'
  os.system('coffee -c js/*.coffee')
else:
  print 'not compiling'    
