# Assignment 2 - Triangle Crawlers
# Author: Alexander Cai

import sys
from random import choice

class TriangleCrawler(object):
	"""A class to model a triangle crawler. We use __slots__ to limit the amount of RAM used by the __dict__ object. of each class."""
	__slots__ = ['pos', 'prevPos']
	def __init__(self):
		self.pos = 0
		self.prevPos = 0

	def move(self):
		# Filter out the current and previous position, and randomly choose one of the remaining ones
		nextPos = choice([p for p in range(np) if p not in (self.pos, self.prevPos)])
		self.pos, self.prevPos = nextPos, self.pos # We unpack values to quickly update the current and previous position

def main():
	global nc, np
	nc = 0 # number of crawlers
	try:
		nc = int(input('How many crawlers do you want to model? (leave empty for default) ')) # We try this in case they give a non-integer value
		assert nc > 0, 'Must be at least one crawler'
	except:
		nc = 100000

	np = 0 # number of points in the graph
	try:
		np = int(input('How many points are there? One will be the Eater of Triangle Crawlers. '))
		assert np >= 2, 'Must be at least 3 points'
	except:
		np = 4
	
	crawlers = [TriangleCrawler() for i in range(nc)] # Create a list of nc crawlers

	total = 0 # Total lifetime of all crawlers

	result = [('Days', '    Crawlers left', '    Total lifetime')]

	count = 1
	while len(crawlers) >= 1:
		for crawler in crawlers:
			total += 1 # Each crawler moves; we check for the death time after
			crawler.move()
		
		# Remove all the dead crawlers from the array. Without loss of generality, we can let np - 1 be the Eater of Triangle Crawlers.
		crawlers = [c for c in crawlers if not c.pos == np - 1] 

		result.append((count, len(crawlers), total))

		count += 1

	col0max = max(len(str(x)) for x in (row[0] for row in result))
	col1max = max(len(str(x)) for x in (row[1] for row in result))
	col2max = max(len(str(x)) for x in (row[2] for row in result))
	for row in result:
		print(str(row[0]).rjust(col0max), str(row[1]).rjust(col1max), str(row[2]).rjust(col2max))
		
	print('The average lifetime was ' + str(total / nc))

if __name__ == "__main__":
	main()