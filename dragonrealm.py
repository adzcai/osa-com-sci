import random
import time

def displayIntro():
 print('You are in a land full of dragons. In front of you,')
 print('you see three caves. In one cave, the dragon is friendly')
 print('and will share his treasure with you. In another cave,')
 print('the dragon is lonely and wants to make friends. The other dragon')
 print('is greedy and hungry, and will eat you on sight.\n')

def chooseCave():
 cave = ''
 while cave not in ['1', '2', '3']:
   print('Which cave will you go into? (1, 2, or 3)')
   cave = input()

 return cave

def checkCave(chosenCave):
 print('You approach the cave...')
 time.sleep(2)
 print('It is dark and spooky...')
 time.sleep(2)
 print('A large dragon jumps out in front of you! He opens his jaws and...')
 print()
 time.sleep(2)

 friendlyCave, greetingCave = random.sample(['1', '2', '3'], 2)

 if chosenCave == friendlyCave:
   print('Gives you his treasure!')
 elif chosenCave == greetingCave:
   print('Says hi and welcomes you in for some tea and biscuits!')
 else:
   print('Gobbles you down in one bite!')

playAgain = 'yes'
while playAgain == 'yes' or playAgain == 'y':
 displayIntro()
 caveNumber = chooseCave()
 checkCave(caveNumber)
 print('Do you want to play again? (yes or no)')
 playAgain = input()
