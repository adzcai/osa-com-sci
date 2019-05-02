# Code based off of Invent Your Own Games with Python 4e (Sweigart, 2016),
# Chapter 9: Extending Hangman
# My extension was adding the clear function, which resets the terminal screen,
# as well as adding categories of words that the user can choose from.

import random, os

clear = lambda: os.system('cls' if os.name == 'nt' else 'clear')

HANGMAN_PICS = ['''
  +---+
      |
      |
      |
     ===''', '''
  +---+
  O   |
      |
      |
     ===''', '''
  +---+
  O   |
  |   |
      |
     ===''', '''
  +---+
  O   |
 /|   |
      |
     ===''', '''
  +---+
  O   |
 /|\  |
      |
     ===''', '''
  +---+
  O   |
 /|\  |
 /    |
     ===''', '''
  +---+
  O   |
 /|\  |
 / \  |
     ===''']

words = {
    'Colors':'red orange yellow green blue indigo violet white black brown'.split(),
    'Shapes':'square triangle rectangle circle ellipse rhombus trapazoid chevron pentagon hexagon septagon octogon'.split(),
    'Fruits':'apple orange lemon lime pear watermelon grape grapefruit cherry banana cantalope mango strawberry tomato'.split(),
    'Animals':'bat bear beaver cat cougar crab deer dog donkey duck eagle fish frog goat leech lion lizard monkey moose mouse otter owl panda python rabbit rat shark sheep skunk squid tiger turkey turtle weasel whale wolf wombat zebra'.split(),
    'Movies':list(map(lambda word: word.lower().replace(' ', '').replace(':', '').replace('–', ''), 'Avatar,Titanic,Star Wars: The Force Awakens,Avengers: Infinity War,Jurassic World,The Avengers,Furious 7,Avengers: Endgame ,Avengers: Age of Ultron,Black Panther,Harry Potter and the Deathly Hallows – Part 2,Star Wars: The Last Jedi,Jurassic World: Fallen Kingdom,Frozen,Beauty and the Beast,Incredibles 2,The Fate of the Furious,Iron Man 3,Minions,Captain America: Civil War'.split(','))) # Join all of the spaces and get rid of special characters
}

def getRandomWord(wordDict, category):
    # This function returns a random string from the passed dictionary of lists of strings.
    wordIndex = random.randint(0, len(wordDict[category]) - 1)

    return wordDict[category][wordIndex]

def displayBoard(missedLetters, correctLetters, category, secretWord):
    clear()
    print(HANGMAN_PICS[len(missedLetters)])
    print('Category: ' + category)
    print()

    print('Missed letters:', end=' ')
    for letter in missedLetters:
        print(letter, end=' ')
    print()

    blanks = '_' * len(secretWord)

    for i in range(len(secretWord)): # replace blanks with correctly guessed letters
        if secretWord[i] in correctLetters:
            blanks = blanks[:i] + secretWord[i] + blanks[i+1:]

    for letter in blanks: # show the secret word with spaces in between each letter
        print(letter, end=' ')
    print()

def getGuess(alreadyGuessed):
    # Returns the letter the player entered. This function makes sure the player entered a single letter, and not something else.
    while True:
        print('Guess a letter.')
        guess = input().lower()
        if len(guess) != 1:
            print('Please enter a single letter.')
        elif guess in alreadyGuessed:
            print('You have already guessed that letter. Choose again.')
        elif guess not in 'abcdefghijklmnopqrstuvwxyz':
            print('Please enter a LETTER.')
        else:
            return guess

def playAgain():
    # This function returns True if the player wants to play again, otherwise it returns False.
    print('Do you want to play again? (yes or no)')
    return input().lower().startswith('y')

def getCategory():
    category = 'X'
    categories = words.keys()
    while category not in categories:
        print('Which category of words do you want to play with?')
        for c in categories:
            print(c)
        category = input().capitalize()
    return category

def main():
    clear()
    print('H A N G M A N')

    missedLetters = ''
    correctLetters = ''
    category = getCategory()
    secretWord = getRandomWord(words, category)
    gameIsDone = False

    while True:
        displayBoard(missedLetters, correctLetters, category, secretWord)

        # Let the player type in a letter.
        guess = getGuess(missedLetters + correctLetters)

        if guess in secretWord:
            correctLetters = correctLetters + guess

            # Check if the player has won
            foundAllLetters = True
            for i in range(len(secretWord)):
                if secretWord[i] not in correctLetters:
                    foundAllLetters = False
                    break
            if foundAllLetters:
                print('Yes! The secret word is "' + secretWord + '"! You have won!')
                gameIsDone = True
        else:
            missedLetters = missedLetters + guess

            # Check if player has guessed too many times and lost.
            if len(missedLetters) == len(HANGMAN_PICS) - 1:
                displayBoard(missedLetters, correctLetters, category, secretWord)
                print('You have run out of guesses!\nAfter ' + str(len(missedLetters)) + ' missed guesses and ' + str(len(correctLetters)) + ' correct guesses, the word was "' + secretWord + '"')
                gameIsDone = True

        # Ask the player if they want to play again (but only if the game is done).
        if gameIsDone:
            if playAgain():
                clear()
                print('H A N G M A N')

                missedLetters = ''
                correctLetters = ''
                category = getCategory()
                secretWord = getRandomWord(words, category)
                gameIsDone = False
            else:
                break

if __name__ == "__main__":
    main()