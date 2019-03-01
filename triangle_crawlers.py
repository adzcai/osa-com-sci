# Assignment 2 - Triangle Crawlers
# Author: Alexander Cai
# Note: the aim of this program was to randomly model the movement of each 
# crawler. Thus, it is not as efficient as it would have been if we used math to 
# calculate the probability directly. Implementing a visual component has
# also slowed it considerably. If you would like to see the program at max speed,
# set WAIT_TIME below to 0. Enjoy!

# Importing used libraries
import pygame, sys
from pygame.locals import *
from math import sin, cos, radians
from random import choice

# Constant variables to store the state of our program
WIDTH = 480
HEIGHT = 480
FPS = 30
WAIT_TIME = 500 # The number of milliseconds between moves, speeds up since the user gets the gist of it
NUM_CRAWLERS = 100000
NUM_RESULTS_TO_SHOW = 15

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
GREEN = (0, 255, 0)

class Crawler(pygame.sprite.Sprite):
	"""A class to model a triangle crawler."""
	def __init__(self, marked):
		pygame.sprite.Sprite.__init__(self)
		self.pos = "A"
		self.prev_pos = "A"
		self.marked = marked # Whether or not this is the crawler we are following

	def update(self):
		self.move()
		if self.pos == last_letter: # If it gets eaten
			self.kill() # We remove it from all groups

	def move(self):
		# Filter out the current and previous position, and randomly choose one of the remaining ones
		nextPos = choice([p for p in letters if p not in (self.pos, self.prev_pos)])
		self.pos, self.prev_pos = nextPos, self.pos # We unpack values to quickly update the current and previous position
		# Update the number of crawlers at each position
		at_positions[self.pos] += 1
		at_positions[self.prev_pos] -= 1

class Day(pygame.sprite.Sprite):
	"""A sprite used to store the current dar"""
	def __init__(self):
		pygame.sprite.Sprite.__init__(self)
		self.font = pygame.font.Font(None, HEIGHT // 24)
		self.font.set_italic(1)
		self.value = 0
		self.update() # Draws its image
		self.rect = self.image.get_rect()
		self.rect.topleft = (10, 10) # Put it in the corner	

	def update(self):
		"""Increments the day and updates the image accordingly."""
		self.value += 1
		self.image = self.font.render(f"Day: {self.value}", True, BLACK)

class Circle(pygame.sprite.Sprite):
	"""A class to display a possible position for a crawler."""
	def __init__(self, x, y, r, letter):
		pygame.sprite.Sprite.__init__(self)
		self.rect = pygame.Rect(x - r, y - r, r * 2, r * 2)
		self.image = pygame.Surface((self.rect.width, self.rect.height))
		self.circle_rect = pygame.Rect(0, 0, self.rect.width, self.rect.height) # Used to draw the actual circle on itself
		self.letter = letter
		self.color = BLACK if letter != last_letter else RED # Make the Eater red
		self.font_size = r // 2
		self.update("A") # Draws its image; the marked crawler starts at "A"

	def update(self, marked_letter):
		"""Updates the image to match the number of crawlers at this circle."""
		self.image.fill(WHITE)
		pygame.draw.ellipse(self.image, self.color if self.letter != marked_letter else GREEN, self.circle_rect, 3)
		draw_text(self.image, self.letter, BLACK, self.font_size, self.rect.width // 2, self.rect.height // 4)
		draw_text(self.image, str(at_positions[self.letter]), BLACK, self.font_size, self.rect.width // 2, self.rect.height // 2)

def draw_text(surf, text, color, size, x, y):
	"""Draws text to :surf: with a given font size."""
	font = pygame.font.Font(None, size) # Gets the default pygame font, which is fine for our purposes
	text_surface = font.render(text, True, color)
	text_rect = text_surface.get_rect()
	text_rect.midtop = (x, y)
	surf.blit(text_surface, text_rect)

def show_start_screen():
	"""Displays a start screen allowing the user to choose how many points there are."""	
	screen.fill(WHITE)

	draw_text(screen, "Triangle Crawler Simulation", BLACK, HEIGHT // 10, WIDTH / 2, HEIGHT // 4)
	draw_text(screen, "By Alexander Cai", BLACK, HEIGHT // 18, WIDTH // 2, HEIGHT // 3)
	draw_text(screen, "The green circle follows the life of a certain crawler", BLACK, HEIGHT // 18, WIDTH // 2, HEIGHT // 2)
	draw_text(screen, "Enter the number of points (>= 4)", BLACK, HEIGHT // 18, WIDTH // 2, HEIGHT * 3 // 4)
	pygame.display.flip()

	waiting = True
	while waiting:
		for event in pygame.event.get():
			if event.type == QUIT:
				pygame.quit()
				sys.exit()
			if event.type == KEYUP:
				try:
					n = int(pygame.key.name(event.key))
					if n >= 4:
						global letters, at_positions, last_letter
						letters = [chr(ord('A') + i) for i in range(n)]
						at_positions = {letter: (NUM_CRAWLERS if letter == "A" else 0) for letter in letters} # Stores the number of crawlers at each position
						last_letter = letters[-1]
						waiting = False
					else:
						draw_text(screen, "That is not a valid choice!", BLACK, HEIGHT // 24, WIDTH // 2, HEIGHT * 7 // 8)
						pygame.display.flip()
				except:
					draw_text(screen, "That is not a valid choice!", BLACK, HEIGHT // 24, WIDTH // 2, HEIGHT * 7 // 8)
					pygame.display.flip()

		clock.tick(FPS)

def show_results(results, total_lifetime, marked_life):
	"""Displays the last NUM_RESULTS_TO_SHOW years of the triangle crawlers in a table to the screen, along with their average lifetime."""
	screen.fill(WHITE)

	font_size = int((HEIGHT - 20) / (NUM_RESULTS_TO_SHOW + 5)) # Divide by the number of total lines
	y = font_size // 4 # The height we start to draw the text at

	draw_text(screen, "The average lifetime was " + str(total_lifetime / NUM_CRAWLERS), BLACK, font_size, WIDTH // 2, y)
	y += font_size
	draw_text(screen, f"The marked crawler lasted {marked_life} days", BLACK, font_size, WIDTH // 2, y)
	y += font_size
	draw_text(screen, f"Last {NUM_RESULTS_TO_SHOW} days shown below", BLACK, font_size, WIDTH // 2, y)
	y += font_size

	results = results[-NUM_RESULTS_TO_SHOW:] # Only show the last 15 results
	results.insert(0, ("Days", "Crawlers left", "Total lifetime"))

	for i in range(NUM_RESULTS_TO_SHOW+1): # For each row of the results
		for j in range(3): # Each of the three columns
			draw_text(screen, str(results[i][j]), BLACK, font_size, (j+1) * WIDTH // 4, y)
		y += font_size
	
	draw_text(screen, "Press enter to simulate again or press a key to end", BLACK, font_size, WIDTH // 2, y)

	pygame.display.flip()

	while True:
		for event in pygame.event.get():
			if event.type == QUIT:
				pygame.quit()
				sys.exit()
			if event.type == KEYUP:
				if event.key == K_RETURN:
					return True # We break out of the program and let it know to go for another run
				else: # Quit the program
					pygame.quit()
					sys.exit()

		clock.tick(FPS)

def restart():
	pygame.quit()
	main()

def main():
	global screen, clock, crawlers

	# Initialize pygame, screen, and clock
	pygame.init()
	screen = pygame.display.set_mode((WIDTH, HEIGHT))
	pygame.display.set_caption("Triangle Crawlers")
	clock = pygame.time.Clock()
	
	# Create all of the crawlers and load them into a pygame group
	crawlers = pygame.sprite.Group(Crawler(False) for i in range(NUM_CRAWLERS - 1))
	marked = Crawler(True) # We mark a crawler and watch its progress
	crawlers.add(marked)
	marked_life = 1

	# Initialize visual components
	day = pygame.sprite.GroupSingle(Day())
	circles = pygame.sprite.Group()
	
	# Waits for the user to select a number of points
	show_start_screen()

	# Set up the geometry of the circles
	r = min(WIDTH, HEIGHT) // 3 # Radius that the circles are placed around
	circler = r // 3 # The radius of each circle
	num_outside_circles = len(letters) - 1
	theta = radians(360 / num_outside_circles) # The angle between the circles
	current_angle = radians(-90) # Makes the top circle vertically above center
	for i in range(num_outside_circles):
		# We use some trig to space them out around a circle
		x = int(WIDTH / 2 + cos(current_angle) * r)
		y = int(HEIGHT / 2 + sin(current_angle) * r)
		circles.add(Circle(x, y, circler, letters[i]))
		current_angle += theta
	circles.add(Circle(WIDTH // 2, HEIGHT // 2, circler, last_letter)) # Add the eater in the center

	result = [] # Stores (Days, Crawlers left, Total lifetime)
	total = len(crawlers) # Total lifetime of all crawlers
	last_move = pygame.time.get_ticks()
	wait_time = WAIT_TIME # We create a new variable so that we can speed it up as the program runs

	while True: # Main loop
		for event in pygame.event.get():
			if event.type == QUIT or event.type == KEYUP and event.key == K_ESCAPE:
				pygame.quit()
				sys.exit()

		if pygame.time.get_ticks() - last_move > wait_time: # We move onto the next day
			# Update all of the groups
			crawlers.update()
			day.update()
			circles.update(marked.pos)
			if marked.alive():
				marked_life += 1 # Keep track of the marked crawler individually

			numcrawlers = len(crawlers)
			total += numcrawlers # All of the crawlers still alive have lived one more day
			result.append((day.sprite.value - 1, numcrawlers, total)) # Should be before the day updates, so we subtract 1

			if numcrawlers == 0: # No crawlers left
				break
				
			last_move = pygame.time.get_ticks() # Set the last move to now
			wait_time *= 7 / 8 # Speed it up exponentially


		# Drawing and rendering
		screen.fill(WHITE)
		day.draw(screen)
		circles.draw(screen)

		pygame.display.flip()
		clock.tick(FPS)

	go_again = show_results(result, total, marked_life) # This shows the results and ends the program when the user clicks
	if go_again:
		restart() # If the program returns (the user wants to go again) we restart the program


if __name__ == "__main__":
	main()
