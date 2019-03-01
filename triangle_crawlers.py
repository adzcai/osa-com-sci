# Assignment 2 - Triangle Crawlers
# Author: Alexander Cai

import pygame, sys
from pygame.locals import *
from math import sin, cos, radians
from random import choice

WIDTH = 480
HEIGHT = 480
FPS = 30
WAIT_TIME = 500
NUM_CRAWLERS = 100000
LETTERS = ("A", "B", "C", "D")
at_positions = {letter: (NUM_CRAWLERS if letter == "A" else 0) for letter in LETTERS }

font_name = pygame.font.match_font('arial')

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)

class Crawler(pygame.sprite.Sprite):
	"""A class to model a triangle crawler."""
	def __init__(self):
		pygame.sprite.Sprite.__init__(self)
		self.pos = "A"
		self.prev_pos = "A"
		self.image = pygame.Surface((10, 10))
		self.image.fill(RED)
		self.rect = self.image.get_rect()

	def update(self):
		self.move()
		if self.pos == "D":
			self.kill()

	def move(self):
		# Filter out the current and previous position, and randomly choose one of the remaining ones
		nextPos = choice([p for p in LETTERS if p not in (self.pos, self.prev_pos)])
		self.pos, self.prev_pos = nextPos, self.pos # We unpack values to quickly update the current and previous position
		at_positions[self.pos] += 1
		at_positions[self.prev_pos] -= 1

class Year(pygame.sprite.Sprite):
	def __init__(self):
		pygame.sprite.Sprite.__init__(self)
		self.font = pygame.font.Font(None, WIDTH // 24)
		self.font.set_italic(1)
		self.color = BLACK
		self.value = 0
		self.update()
		self.rect = self.image.get_rect().move(10, 450)
		
	def update(self):
		self.value += 1
		msg = f"Year: {self.value}"
		self.image = self.font.render(msg, 0, self.color)

class Circle(pygame.sprite.Sprite):
	def __init__(self, x, y, r, letter):
		pygame.sprite.Sprite.__init__(self)
		self.rect = pygame.Rect(x - r, y - r, r * 2, r * 2)
		self.image = pygame.Surface((self.rect.width, self.rect.height))
		self.circle_rect = pygame.Rect(0, 0, self.rect.width, self.rect.height)
		self.image.fill(WHITE)
		self.letter = letter

	def update(self):
		pygame.draw.ellipse(self.image, BLACK, self.circle_rect, 3)
		draw_text(self.image, self.letter, BLACK, 24, self.rect.width // 2, self.rect.height // 4)
		draw_text(self.image, str(at_positions[self.letter]), BLACK, 20, self.rect.width // 2, self.rect.height // 2)

def draw_text(surf, text, color, size, x, y):
	"""Draws text to :surf: with a given font size."""
	font = pygame.font.Font(font_name, size)
	text_surface = font.render(text, True, color)
	text_rect = text_surface.get_rect()
	text_rect.midtop = (x, y)
	surf.blit(text_surface, text_rect)

def draw_arrow(p1=(0, 0), p2=(0, 0), direction="left"):
	"""Draws an arrow (line with a tick at the end) from p1 to p2 with the tick facing *direction*."""
	v = pygame.math.Vector2(p2[0] - p1[0], p2[1] - p1[1])
	ahlen = v.length() // 24
	ahhor = ahlen * 2 / 3
	v.normalize_ip()

	perp = pygame.math.Vector2(-v.y, v.x)

	lastp = []

	if direction == "left":
		lastp = (p2[0] - ahlen * v.x + ahhor * perp.x, p2[1] - ahlen * v.y + ahhor * perp.y)
	else:
		lastp = (p2[0] - ahlen * v.x - ahhor * perp.x, p2[1] - ahlen * v.y - ahhor * perp.y)

	pygame.draw.lines(screen, BLACK, False, (p1, p2, lastp))

def show_start_screen():	
	screen.fill(WHITE)

	draw_text(screen, "Triangle Crawler Simulation", BLACK, HEIGHT // 10, WIDTH / 2, HEIGHT // 4)
	draw_text(screen, "By Alexander Cai", BLACK, HEIGHT // 18, WIDTH // 2, HEIGHT // 2)
	draw_text(screen, "Press any key to begin", BLACK, HEIGHT // 24, WIDTH // 2, HEIGHT * 3 // 4)
	pygame.display.flip()

	waiting = True
	while waiting:
		for event in pygame.event.get():
			if event.type == QUIT:
				pygame.quit()
				sys.exit()
			if event.type == KEYUP:
				waiting = False

		clock.tick(FPS)

def show_results(result, total_lifetime):
	colmaxes = {i: max(len(str(x)) for x in (row[i] for row in result)) for i in range(3)} # Use a big old dict comprehension to nicely pack up the values
	for row in result:
		print(' '.join(str(row[i]).rjust(colmaxes[i]) for i in range(3)))
		
	print("The average lifetime was " + str(total_lifetime / NUM_CRAWLERS))

def main():
	global screen, clock, crawlers

	# Initialize pygame, screen, and clock
	pygame.init()
	screen = pygame.display.set_mode((WIDTH, HEIGHT))
	pygame.display.set_caption("Triangle Crawlers")
	clock = pygame.time.Clock()

	font = pygame.font.match_font("arial")
		
	crawlers = pygame.sprite.Group(Crawler() for i in range(NUM_CRAWLERS))
	year = pygame.sprite.GroupSingle(Year())
	circles = pygame.sprite.Group()
	
	r = min(WIDTH, HEIGHT) // 3
	circler = r // 3
	for i in range(3):
		theta = radians(120 * i)
		x = int(WIDTH / 2 + cos(theta) * r)
		y = int(HEIGHT / 2 + sin(theta) * r)
		circles.add(Circle(x, y, circler, LETTERS[i]))
	circles.add(Circle(WIDTH // 2, HEIGHT // 2, circler, "D"))

	result = [("Days", "    Crawlers left", "    Total lifetime")]
	total = 0 # Total lifetime of all crawlers
	last_move = 0

	show_start_screen()

	while True: # Main game loop
		for event in pygame.event.get():
			if event.type == QUIT or event.type == KEYUP and event.key == K_ESCAPE:
				pygame.quit()
				sys.exit()

		if pygame.time.get_ticks() - last_move > WAIT_TIME: # We move onto the next year
			crawlers.update()
			year.update()
			numcrawlers = len(crawlers)
			total += numcrawlers
			result.append((year.sprite.value, numcrawlers, total))

			if numcrawlers == 0:
				show_results(result, total)
				pygame.quit()
				sys.exit()
			last_move = pygame.time.get_ticks()

		circles.update()

		screen.fill(WHITE)
		year.draw(screen)
		circles.draw(screen)

		pygame.display.flip()
		clock.tick(FPS)

	show_results(result, total)

if __name__ == "__main__":
	main()