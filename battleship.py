# Assignment 3 - Battleship

# Battleship is a war-themed board game for two players in which the opponents try to guess the location of the other's various ships. A paper and pencil version of the game dates back to World War I, but most people are familiar with the game through the plastic board game that was first marketed by the Milton Bradley Company in 1967. Since then, the game has spawned various video games and smartphone app variations. Today, the board game version is produced by Hasbro, which acquired Milton Bradley in 1984. 
 
# The object of the game is to guess the location of the ships each player hides on a plastic grid containing vertical and horizontal space coordinates. Players take turns calling out row and column coordinates on the other player's grid in an attempt to identify a square that contains a ship. 
 
# The game board each player gets has two grids. One of the grids is used by the player to "hide" the location of his own ships, while the other grid is used to record the shots fired toward the opponent and to document whether those shots were hits or misses. The goal of the game is to sink all of the opponent's ships by correctly guessing their location on the grid. 

# Create a program for the user to play against the computer. Instead of each player having ships and their own grid, only the computer does. The computer will strategically place three ships that are 3 squares each on the grid and the user will try to guess their location in the minimum amount of guesses. For this game you must use a two dimensional array (7 x 7).  Randomly assign the placement of the ships to the grid. Once the ships are in place, the user should try to guess the location of each ship.  The game should keep track of the amount of guesses from the user. 
# Add creativity to this game and go beyond the assignment requirements. Also try to be as efficient as possible with your code.

# When the project is complete please submit a folder with all of your files. Present your program to your teacher and answer questions about the code and overall program. 

# Marks will be awarded based on the following:

# Project Requirements and Understanding / 30 marks
# Planning and Coding / 30 marks
# Program Design / 20 marks
# Creativity and Extension / 20 marks

from random import randint
from collections import namedtuple
import sys

Point = namedtuple('Point', ['r', 'c'])

NUM_COLS = 7
NUM_ROWS = 7
SHIP_LENGTH = 3
EMPTY = '_'

class Grid:
  def __init__(self):
    self.grid = [[EMPTY for _ in range(NUM_COLS)] for __ in range(NUM_ROWS)]
    self.display_grid = [[' ' for _ in range(NUM_COLS)] for __ in range(NUM_ROWS)]
    self.ships = dict()
    self.moves = 0

  def place_ships(self):
    to_place = 3
    while to_place > 0:
      if randint(0, 1): # Arbitrarily, this means a vertical ship
        top = Point(randint(0, NUM_ROWS - SHIP_LENGTH), randint(0, NUM_COLS - 1))
        if all(self.grid[top.r + i][top.c] == EMPTY for i in range(3)):
          for i in range(3):
            self.grid[top.r + i][top.c] = to_place
          self.ships[to_place] = SHIP_LENGTH
          to_place -= 1
      else: # Horizontal
        left = Point(randint(0, NUM_ROWS - 1), randint(0, NUM_COLS - SHIP_LENGTH))
        if all(self.grid[left.r][left.c + i] == EMPTY for i in range(3)):
          for i in range(3):
            self.grid[left.r][left.c + i] = to_place
          self.ships[to_place] = SHIP_LENGTH
          to_place -= 1

  def display(self):
    print('|'.join(f' {chr(ord("A") + i - 1) if i > 0 else " "} ' for i in range(NUM_COLS + 1)))
    for i, row in enumerate(self.display_grid):
      print('-'.join(['---'] * (NUM_COLS + 1)))
      print(f' {i + 1} | ' + ' | '.join(map(str, row)))

  def guess(self, r, c):
    print(r)
    print(c)
    if self.grid[r][c] == EMPTY:
      self.place(r, c, 'O')
      self.display()
      print('Miss')
      self.moves += 1

    elif isinstance(self.grid[r][c], int):
      ship_id = self.grid[r][c]

      self.place(r, c, 'X')
      self.display()
      print('Hit!')
      self.moves += 1

      self.ships[ship_id] -= 1
      if self.ships[ship_id] == 0:
        print('You sunk a ship!')

    else:
      print('That move is already taken!')

    print(f'Moves: {self.moves}')

  def place(self, r, c, val):
    self.grid[r][c] = val
    self.display_grid[r][c] = val

def show_help():
  print('Enter your guesses in the format A1')

def main():
  grid = Grid()
  grid.place_ships()
  grid.display()
  show_help()

  while sum(grid.ships.values()) > 0:
    inpt = input('Enter your move, "exit", or "help": ')

    if inpt == 'exit':
      return
    elif inpt == 'help': 
      show_help()
    elif len(inpt) == 2 and inpt[0].isalpha() and inpt[1].isdigit():
      c, r = inpt
      r = int(r) - 1
      c = ord(c.upper()) - ord('A')
      
      if 0 <= c and c < NUM_COLS and 0 <= r and r < NUM_ROWS:
        grid.guess(r, c)
      else:
        print('That was not a valid move!')
    else:
      print('That was not a valid input!')

  resp = input('You won! Play again?')
  if resp.lower().startswith('y'):
    main()
  else:
    return

if __name__ == "__main__":
  main()
