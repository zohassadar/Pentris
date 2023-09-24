import re
import sys


pointsfile = open(sys.argv[1]).read()

points = map(int, re.findall(r'\d+', pointsfile))


print(sum(points))