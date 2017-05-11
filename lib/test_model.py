import sys

with open('tmp/file_with_params.txt', 'wb') as file:
  file.write(str(sys.argv[1:5]).replace("[", "").replace("]", "")) 

print 1