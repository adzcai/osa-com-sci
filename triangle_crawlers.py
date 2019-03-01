# Assignment 2 - Triangle Crawlers
# Author: Alexander Cai

# Importing used libraries
import pygame, sys
from pygame.locals import *
from math import sin, cos, radians
from random import choice

# Constant variables to store the state of our program
WIDTH = 480
HEIGHT = 480
FPS = 30
WAIT_TIME = 500 # The number of milliseconds between moves
NUM_CRAWLERS = 100000
LETTERS = ("A", "B", "C", "D")
at_positions = {letter: (NUM_CRAWLERS if letter == "A" else 0) for letter in LETTERS} # Stores the number of crawlers at each position

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

class Day(pygame.sprite.Sprite):
	"""A sprite used to store the current dar"""
	def __init__(self):
		pygame.sprite.Sprite.__init__(self)
		self.font = pygame.font.Font(None, WIDTH // 24)
		self.font.set_italic(1)
		self.value = 0
		self.update()
		self.rect = self.image.get_rect()
		self.rect.bottomleft = (10, HEIGHT - 10)
		
	def update(self):
		self.value += 1
		msg = f"Day: {self.value}"
		self.image = self.font.render(msg, 0, BLACK)

class Circle(pygame.sprite.Sprite):
	"""A class to display a possible position for a crawler."""
	def __init__(self, x, y, r, letter):
		pygame.sprite.Sprite.__init__(self)
		self.rect = pygame.Rect(x - r, y - r, r * 2, r * 2)
		self.image = pygame.Surface((self.rect.width, self.rect.height))
		self.circle_rect = pygame.Rect(0, 0, self.rect.width, self.rect.height)
		self.letter = letter

	def update(self):
		"""Updates the image to match the number of crawlers at this circle."""
		self.image.fill(WHITE)
		pygame.draw.ellipse(self.image, BLACK, self.circle_rect, 3)
		draw_text(self.image, self.letter, BLACK, 24, self.rect.width // 2, self.rect.height // 4)
		draw_text(self.image, str(at_positions[self.letter]), BLACK, 20, self.rect.width // 2, self.rect.height // 2)

def draw_text(surf, text, color, size, x, y):
	"""Draws text to :surf: with a given font size."""
	font = pygame.font.Font(None, size) # Gets the default pygame font, which is fine for our purposes
	text_surface = font.render(text, True, color)
	text_rect = text_surface.get_rect()
	text_rect.midtop = (x, y)
	surf.blit(text_surface, text_rect)

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
	screen.fill(WHITE)
	
	font_size = int((HEIGHT * 3 / 4) // len(result))
	start_height = HEIGHT // 8

	draw_text(screen, "The average lifetime was " + str(total_lifetime / NUM_CRAWLERS), BLACK, 24, WIDTH // 2, 10)

	for i in range(len(result)): # For each row of the results
		for j in range(3): # Each of the three columns
			draw_text(screen, str(result[i][j]), BLACK, font_size, (j+1) * WIDTH // 4, start_height + i * font_size)
	
	draw_text(screen, "Press enter to simulate again or press a key to end", BLACK, 24, WIDTH // 2, HEIGHT - 24 - 10)

	pygame.display.flip()

	waiting = True
	while waiting:
		for event in pygame.event.get():
			if event.type == QUIT:
				pygame.quit()
				sys.exit()
			if event.type == KEYUP:
				if event.key == K_RETURN:
					waiting = False
				else:
					pygame.quit()
					sys.exit()

		clock.tick(FPS)
		
def main():
	global screen, clock, crawlers

	# Initialize pygame, screen, and clock
	pygame.init()
	screen = pygame.display.set_mode((WIDTH, HEIGHT))
	pygame.display.set_caption("Triangle Crawlers")
	clock = pygame.time.Clock()

	font = pygame.font.match_font("arial")
		
	crawlers = pygame.sprite.Group(Crawler() for i in range(NUM_CRAWLERS))
	day = pygame.sprite.GroupSingle(Day())
	circles = pygame.sprite.Group()
	
	r = min(WIDTH, HEIGHT) // 3
	circler = r // 3
	for i in range(3):
		theta = radians(120 * i - 90) # - 90 makes the top one vertically above center
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

		if pygame.time.get_ticks() - last_move > WAIT_TIME: # We move onto the next Day
			crawlers.update()
			day.update()
			circles.update()

			numcrawlers = len(crawlers)
			total += numcrawlers
			result.append((day.sprite.value - 1, numcrawlers, total)) # Should be before the Day updates

			if numcrawlers == 0:
				show_results(result, total) # This shows the results and ends the program when the user clicks
				global at_positions
				at_positions = {letter: (NUM_CRAWLERS if letter == "A" else 0) for letter in LETTERS } # Reset the crawlers at each point
				main() # Restart the program
				
			last_move = pygame.time.get_ticks() # Set the last move to now

		# Drawing and rendering
		screen.fill(WHITE)
		day.draw(screen)
		circles.draw(screen)

		pygame.display.flip()
		clock.tick(FPS)

	show_results(result, total)

if __name__ == "__main__":
	main()