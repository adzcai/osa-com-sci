"""
Assignment 2 - Zero Hour 
 
Zero Hour was produced by Universal in 1981.
 
Maneuver your spaceship and destroy meteorites and enemy ships falling from the top of the screen. Shooting a red meteorite awards a quadruple score. After all enemy ships have been destroyed, a landing pad will appear where you must carefully land your ship. Bonus points are awarded for a successful landing.

https://www.youtube.com/watch?v=2cEry3SVl78

https://www.arcade-museum.com/game_detail.php?game_id=10526

http://kidscancode.org/lessons/

Assignment: Continue and add to the program the Space Shooter SHMUP game that we started in class. Please use the 1981 arcade game Zero Hour as a reference. The game that you create should keep score, track of lives, includes different objects falling towards the player and have a Game Over screen.  The enemy (mob) objects can have the same behaviour per level.

Add creativity to this game and go beyond the assignment requirements.

When the project is complete please submit a folder with all of your files. Present your program to your teacher and answer questions about the code and overall program. 

Marks will be awarded based on the following:

Project Requirements and Understanding / 30 marks
Planning and Coding / 30 marks
Program Design / 20 marks
Creativity and Extension / 20 marks

https://game-development.zeef.com/david.arcila 
https://kenney.nl/assets/space-shooter-extension
"""

# ==================== IMPORT MODULES ====================

import math, os.path, pygame, random, sys, time
from pygame.locals import *

# ==================== CONSTANTS ====================

FPS = 30 # frames per second to update the screen
WINWIDTH = 640 # width of the program's window, in pixels
WINHEIGHT = 480 # height in pixels
HALF_WINWIDTH = WINWIDTH // 2
HALF_WINHEIGHT = WINHEIGHT // 2

BGCOLOR = (  0,   0,   0)
WHITE   = (255, 255, 255)
RED     = (255,   0,   0)

MAXHEALTH = 3        # how much health the player starts with

ACCELSPEED = 9         # how fast the player moves
MAXSPEED = 10        # the fastest speed the player can move

INVULNTIME = 2       # how long the player is invulnerable after being hit in seconds
ANIMTIME = 1         # how often the spaceship animations change frames
GAMEOVERTIME = 4     # how long the "game over" text stays on the screen in seconds

main_dir = os.path.split(os.path.abspath(__file__))[0]

# ==================== LOADING RESOURCES ====================

if not pygame.font: print('Warning, fonts disabled')
if not pygame.mixer: print('Warning, sound disabled')

def load_image(name, colorkey=None):
	fullname = os.path.join('data', name)
	try:
		image = pygame.image.load(fullname)
	except pygame.error as message:
		print('Cannot load image:', name)
		raise SystemExit(message)
	image = image.convert()
	if colorkey is not None:
		if colorkey is -1:
			colorkey = image.get_at((0,0))
		image.set_colorkey(colorkey, RLEACCEL)
	return image, image.get_rect()

def loadSound(name):
	class NoneSound:
		def play(self): pass
	if not pygame.mixer:
		return NoneSound()
	fullname = os.path.join('data', name)
	try:
		sound = pygame.mixer.Sound(fullname)
	except pygame.error as message:
		print('Cannot load sound:', wav)
		raise SystemExit(message)
	return sound

def makeText(text, font=BASICFONT, aa=True, color=WHITE, bg=None):
	textSurf = font.render(text, aa, color, bg)
	return textSurf, textSurf.get_rect()

# ==================== GAME OBJECT CLASSES ====================

class PlayerShip(pygame.sprite.Sprite):
	"""A simple class to store data about the ship the player controls.
	
	Extends pygame.sprite.Sprite, inheriting the update, add, remove, kill, alive, and groups methods."""

	def __init__(self):
		pygame.sprite.Sprite.__init__(self)
		self.og_image, self.rect = load_image('playership.png')
		self.image = self.og_image.copy()

	# Booleans and timers for various player actions
		self.firing_start_time = 0
		self.invulnerable = False
		self.invulnerable_timer = -1

	# Vectors to control the ship's movement and position
		self.rect.center = (WINWIDTH / 2, WINHEIGHT * 7 / 8)
		self.vel = pygame.math.Vector2(0, 0)
		self.accel = pygame.math.Vector2(0, 0)
	
	def update(self):
		self.accel *= 0 # Reset acceleration

		if pygame.key.get_focused(): # If the screen is currently active and receiving input
			keys = pygame.key.get_pressed()
			if keys[K_LEFT] or keys[K_a]:
				self.accel.x -= ACCELSPEED
			elif keys[K_RIGHT] or keys[K_d]:
				self.accel.x += ACCELSPEED
			
			if keys[K_UP] or keys[K_w]:
				self.accel.y -= ACCELSPEED
			elif keys[K_DOWN] or keys[K_s]:
				self.accel.y += ACCELSPEED

	# Use the vectors to move the rectangle
		self.vel += self.accel
		if self.vel.length >= MAXSPEED:
			self.vel.scale_to_length(MAXSPEED)
		self.rect.move_ip(self.vel.x, self.vel.y)

		if self.rect.left > WINWIDTH:
			self.rect.right = 0
		elif self.rect.right < 0:
			self.rect.left = WINWIDTH

	# Check if we should turn off invulnerability
		if self.invulnerable and time.time() - self.invulnerableStartTime > INVULNTIME:
			self.invulnerable = False

	# draw the player flash
		flashIsOn = round(time.time(), 1) * 10 % 2 == 1
		if self.invulnerable and flashIsOn:
			self.image
		
	# check collisions
		if self.check_collisions():
			gameOverMode = True # turn on "game over mode"
			gameOverStartTime = time.time()

	def check_collisions(self):
		"""Checks if the player has collided with any obstacles or ships."""
		if not self.invulnerable:
			for enemy_ship in pygame.sprite.sprite_collide(self, enemies, True):
				player.invulnerable = True
				player.invulnerable_start_time = time.time()
				player.health -= 1
				return self.health == 0

	def fire(self):
		self.firingStartTime = time.time()
	
class Explosion(pygame.sprite.Sprite):
    defaultlife = 12
    animcycle = 3
    images = []
    def __init__(self, actor):
        pygame.sprite.Sprite.__init__(self, self.containers)
        self.image = self.images[0]
        self.rect = self.image.get_rect(center=actor.rect.center)
        self.life = self.defaultlife

    def update(self):
        self.life = self.life - 1
        self.image = self.images[self.life//self.animcycle%2]
        if self.life <= 0: self.kill()

class EnemyShip(pygame.sprite.Sprite):
	def __init__(self, type):
		pygame.sprite.Sprite.__init__(self)
		self.image, self.rect = load_image(imgUrl)

		generalSize = random.randint(5, 25)
		multiplier = random.randint(1, 3)
		
		self.rect.center = getRandomOffCameraPos(camerax, cameray, sq['width'], sq['height'])
		
		self.vel = pygame.math.Vector2()

	def update():
		if self.rect.left < 0 or self.rect.right > WINWIDTH:
			self.dx = -self.dx

	def bounce(currentBounce, bounceRate, bounceHeight):
		# Returns the number of pixels to offset based on the bounce.
		# Larger bounceRate means a slower bounce.
		# Larger bounceHeight means a higher bounce.
		# currentBounce will always be less than bounceRate
		return int(math.sin( (math.pi / float(bounceRate)) * currentBounce ) * bounceHeight)

class Shot(pygame.sprite.Sprite):
    speed = -11
    images = []
    def __init__(self, pos):
        pygame.sprite.Sprite.__init__(self, self.containers)
        self.image = self.images[0]
        self.rect = self.image.get_rect(midbottom=pos)

    def update(self):
        self.rect.move_ip(0, self.speed)
        if self.rect.top <= 0:
            self.kill()
		
# ==================== MAIN PROGRAM ====================

def main():
	global FPSCLOCK, DISPLAYSURF, BASICFONT, PLAYERSHIP_IMG, SPACESHIP_IMGS

	pygame.init()
	FPSCLOCK = pygame.time.Clock()
	DISPLAYSURF = pygame.display.set_mode((WINWIDTH, WINHEIGHT))
	pygame.display.set_caption('Zero Hour - Alexander Cai')
	BASICFONT = pygame.font.Font('freesansbold.ttf', 32)

	# load the image files
	SPACESHIP_IMGS = [Animation([pygame.image.load('spaceship1.png')])]
	for i in range(2, 4):
		SPACESHIP_IMGS.append(Animation([pygame.image.load('spaceship%s_%s.png' % (i, j)) for j in (1, 2)]))

	level = 0
	while True:
		runGame(level)

def runGame(level):
# set up variables for the start of a new game
	gameOverMode = False      # if the player has lost
	gameOverStartTime = 0     # time the player lost
	winMode = False           # if the player has won

# create the surfaces to hold game text
	gameOverSurf = BASICFONT.render('Game Over', True, WHITE)
	gameOverRect = gameOverSurf.get_rect()
	gameOverRect.center = (HALF_WINWIDTH, HALF_WINHEIGHT)

	winSurf = BASICFONT.render('You have achieved OMEGA SQUIRREL!', True, WHITE)
	winRect = winSurf.get_rect()
	winRect.center = (HALF_WINWIDTH, HALF_WINHEIGHT)

	winSurf2 = BASICFONT.render('(Press "r" to restart.)', True, WHITE)
	winRect2 = winSurf2.get_rect()
	winRect2.center = (HALF_WINWIDTH, HALF_WINHEIGHT + 30)

# create the sprites to store our main player character and the enemies
	all_sprites = pygame.sprite.RenderPlain(PlayerShip())

# ==================== MAIN GAME LOOP ====================

	while True:
	# fill the background
		DISPLAYSURF.fill(BGCOLOR)

	# draw the sprites
		all_sprites.update()

	# if the game is not over
		if not gameOverMode:
			pass
		else:
			# game is over, show "game over" text
			DISPLAYSURF.blit(gameOverSurf, gameOverRect)
			if time.time() - gameOverStartTime > GAMEOVERTIME:
				return # end the current game

		# check if the player has won.
		if winMode:
			DISPLAYSURF.blit(winSurf, winRect)
			DISPLAYSURF.blit(winSurf2, winRect2)

		for event in pygame.event.get():
			if event.type == QUIT or event.type == KEYUP and event.key == K_ESCAPE:
				pygame.quit()
				sys.exit()
				
		pygame.display.update()
		FPSCLOCK.tick(FPS)




def drawHealthMeter(currentHealth):
	for i in range(currentHealth): # draw red health bars
		pygame.draw.rect(DISPLAYSURF, RED,   (15, 5 + (10 * MAXHEALTH) - i * 10, 20, 10))
	for i in range(MAXHEALTH): # draw the white outlines
		pygame.draw.rect(DISPLAYSURF, WHITE, (15, 5 + (10 * MAXHEALTH) - i * 10, 20, 10), 1)

# def getRandomVelocity():
# 	speed = random.randint(SQUIRRELMINSPEED, SQUIRRELMAXSPEED)
# 	if random.randint(0, 1) == 0:
# 		return speed
# 	else:
# 		return -speed


def getRandomOffCameraPos(camerax, cameray, objWidth, objHeight):
	# create a Rect of the camera view
	cameraRect = pygame.Rect(camerax, cameray, WINWIDTH, WINHEIGHT)
	while True:
		x = random.randint(camerax - WINWIDTH, camerax + (2 * WINWIDTH))
		y = random.randint(cameray - WINHEIGHT, cameray + (2 * WINHEIGHT))
		# create a Rect object with the random coordinates and use colliderect()
		# to make sure the right edge isn't in the camera view.
		objRect = pygame.Rect(x, y, objWidth, objHeight)
		if not objRect.colliderect(cameraRect):
			return x, y


if __name__ == '__main__':
	main()