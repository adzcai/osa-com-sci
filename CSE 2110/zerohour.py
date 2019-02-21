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
"""

import pygame, sys
from pygame.locals import *

FPS = 30
WINDOWWIDTH = 480
WINDOWHEIGHT = 640

#            R    G    B
BLACK    = (  0,   0,   0)
WHITE    = (255, 255, 255)
GRAY     = (100, 100, 100)
NAVYBLUE = ( 60,  60, 100)
WHITE    = (255, 255, 255)
RED      = (255,   0,   0)
GREEN    = (  0, 255,   0)
BLUE     = (  0,   0, 255)
YELLOW   = (255, 255,   0)
ORANGE   = (255, 128,   0)
PURPLE   = (255,   0, 255)
CYAN     = (  0, 255, 255)

BGCOLOR = BLACK

def main():
    global FPSCLOCK, DISPLAYSURF, BASICFONT
    pygame.init()
    FPSCLOCK = pygame.time.Clock()
    DISPLAYSURF = pygame.display.set_mode((WINDOWWIDTH, WINDOWHEIGHT))
    BASICFONT = pygame.font.get_fonts()
    pygame.display.set_caption('Zero Hour')
    
    mousex = 0
    mousey = 0

    DISPLAYSURF.fill(BGCOLOR)
    while True: # main game loop
        for event in pygame.event.get():
            if event.type == QUIT or (event.type == KEYUP and event.key == K_ESCAPE):
                pygame.quit()
                sys.exit()
            elif event.type == MOUSEMOTION:
                mousex, mousey = event.pos
        
        pygame.display.update()
        FPSCLOCK.tick()

def text(text, color, bgcolor, top, left, font=BASICFONT):
    textSurf = font.render(text, True, color, bgcolor)
    textRect = surf.get_rect()
    textRect.topleft = (top, left)


def mainMenuAnimation():
  pass
