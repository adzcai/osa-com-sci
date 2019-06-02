# Assignment 3 - Battleship
# By Alexander Cai
# For the Javascript version of my code with better graphics, see
# https://github.com/piguyinthesky/react-tleship

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
