# Assignment 2 - Triangle Crawlers
# Author: Alexander Cai

import sys, pygame
from random import choice

WIDTH = 480
HEIGHT = 480

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

def draw_crawlers():
	for i in range(3):
		

def main():
	global screen, clock

	pygame.init()
	screen = pygame.display.set_mode((WIDTH, HEIGHT))
	pygame.display.set_caption('Triangle Crawlers - Alexander Cai')

	nc = 100000
	np = 4

	crawlers = [TriangleCrawler() for i in range(nc)] # Create a list of nc crawlers

	total = 0 # Total lifetime of all crawlers

	count = 1
	while len(crawlers) >= 1:
		for crawler in crawlers:
			total += 1 # Each crawler moves; we check for the death time after
			crawler.move()
		
		# Remove all the dead crawlers from the array. Without loss of generality, we can let np - 1 be the Eater of Triangle Crawlers.
		crawlers = [c for c in crawlers if not c.pos == np - 1] 

		print('After year ' + str(count) + ': ' + str(len(crawlers)) + ' crawlers left. Total lifetime: ' + str(total))

		count += 1
		
	print('The average lifetime was ' + str(total / nc))

if __name__ == "__main__":
	main()