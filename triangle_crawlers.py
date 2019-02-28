# Assignment 2 - Triangle Crawlers
# Author: Alexander Cai

import sys, pygame
from pygame.locals import *
from random import choice

WIDTH = 480
HEIGHT = 480
FPS = 30
WAIT_TIME = 500
NUM_CRAWLERS = 100000
LETTERS = ('A', 'B', 'C', 'D')

WHITE = (255, 255, 255)
RED = (255, 0, 0)

def draw_text(surf, text, size, x, y):
    """Draws text to :surf: with a given font size."""
    font = pygame.font.Font(font_name, size)
    text_surface = font.render(text, True, WHITE)
    text_rect = text_surface.get_rect()
    text_rect.midtop = (x, y)
    surf.blit(text_surface, text_rect)

class Crawler(pygame.sprite.Sprite):
	"""A class to model a triangle crawler."""
	def __init__(self):
		pygame.sprite.Sprite.__init__(self)
		self.pos = 0
		self.prevPos = 0
		self.image = pygame.Surface((10, 10))
		self.image.fill(RED)
		self.rect = self.image.get_rect()

	def update(self):
		self.move()
		if self.pos != 'D': # If it has moved to a safe position
			global total
			total += 1
		else:
			self.kill()

	def move(self):
		# Filter out the current and previous position, and randomly choose one of the remaining ones
		nextPos = choice([p for p in LETTERS if p not in (self.pos, self.prevPos)])
		self.pos, self.prevPos = nextPos, self.pos # We unpack values to quickly update the current and previous position

class Year(pygame.sprite.Sprite):
	def __init__(self):
		pygame.sprite.Sprite.__init__(self)
		self.font = pygame.font.Font(None, WIDTH // 24)
		self.font.set_italic(1)
		self.color = WHITE
		self.value = 0
		self.update()
		self.rect = self.image.get_rect().move(10, 450)
		
	def update(self):
		self.value += 1
		msg = f"Year: {self.value}"
		self.image = self.font.render(msg, 0, self.color)

def show_results(result, total_lifetime):
	colmaxes = {i: max(len(str(x)) for x in (row[i] for row in result)) for i in range(3)} # Use a big old
	for row in result:
		print(str(row[i]).rjust(colmaxes[i]) for i in range(3))
		
	print('The average lifetime was ' + str(total_lifetime / NUM_CRAWLERS))

def main():
	global screen, clock, crawlers

	# Initialize pygame, screen, and clock
	pygame.init()
	screen = pygame.display.set_mode((WIDTH, HEIGHT))
	pygame.display.set_caption('Triangle Crawlers')
	clock = pygame.time.Clock()

	font = pygame.font.match_font('arial')
		
	crawlers = pygame.sprite.RenderUpdates(Crawler() for i in range(NUM_CRAWLERS))
	year = pygame.sprite.GroupSingle(Year())

	result = [('Days', '    Crawlers left', '    Total lifetime')]
	total = 0 # Total lifetime of all crawlers
	last_move = 0

	waiting = True
	
	draw_text(screen, "Triangle Crawler Simulation", HEIGHT // 10, WIDTH / 2, HEIGHT // 4)
	draw_text(screen, "By Alexander Cai", HEIGHT // 18, WIDTH // 2, HEIGHT // 2)
	draw_text(screen, "Press any key to begin", HEIGHT // 24, WIDTH // 2, HEIGHT * 3 // 4)

	while True: # Main game loop
		screen.fill(WHITE)

		for event in pygame.event.get():
			if event.type == QUIT or event.type == KEYUP and event.key == K_ESCAPE:
				pygame.quit()
				sys.exit()

		if pygame.time.get_ticks() - last_move > WAIT_TIME: # We move onto the next year
			crawlers.update()
			year.update()
			result.append((years, len(crawlers), total))

		clock.tick(FPS)

	show_results(result, total)

if __name__ == "__main__":
	main()