# Description: http://classroom.google.com/c/Mjc4NTQ4NDcyOTNa/a/MzIxMjIyNTUyMDZa/details
# Notes: this program uses a lot of regular expressions, which we haven't covered in class
# but I thought were necessary to  write the program as I did.
# To make my code neater, I used python f-strings to quickly format a variable
# into a string. My extension was implementing the famous math card game 24. Thank you!

from re import search
from random import randint
import os

def clear(): # Clears the terminal (cross-platform, from StackOverflow)
    os.system('cls' if os.name == 'nt' else 'clear')

# These are short, one-line functions, so using lambdas might be neater code;
# however, I thought it best to follow the assignment requirements
def add(x, y):
    return x + y
def subtract(x, y):
    return x - y
def multiply(x, y):
    return x * y
def divide(x, y):
    return x / y

operators = {
    "+": add,
    "-": subtract,
    "*": multiply,
    "/": divide
}

# My implementation of the classic math card game, 24.
# As default, we get 4 random playing card values, from 1 (A) to 13 (K), 
# although specific sets of cards can be passed.
def game(first_time, cards=False):
    clear()
    # Shorthand for returning out if they don't want to play
    if first_time and not get_yes_no("Welcome to the 24 Game! Would you like to play (yes or no)? "):
        return

    if not cards:
        # We don't actually care if they leave this blank, as long as there's multiple items
        custom_cards = [s.strip() for s in input("If you have a custom set of cards, please enter them separated by commas (e.g. 1,2,3,4). If not, press enter. ").split(",")]

        if all([search("^\d+$", s) for s in custom_cards]):
            cards = custom_cards
        else:
            cards = [str(randint(1, 13)) for i in range(4)]

    og_cards = cards[:]

    expr = ""
    expected = "a number"
    depth = 0

    while True:
        print(f"Your remaining numbers are: {', '.join(cards)}")
        print(f"Your current expression: {expr}")
        guess = input(f"Please enter {expected}, \"backspace\", \"exit\", \"help\", or \"restart\": ").strip().lower()
        clear() # We clear after accepting user input

        if search(r"^(b(ack)?(space)?|u(ndo)?)$", guess):
            ending_num = search(r"\d+$", expr) # Does the expression end with a number
            if ending_num:
                start, end = ending_num.span()
                num_len = end - start
                expr = expr[:-num_len] # We remove that number off the end
                cards.append(ending_num.string)
                expected = "a number"
            elif len(expr) > 0: # We remove the operator at the end, so that a number comes before.
                expr = expr[:-1]
                expected = "an operator"

        elif search(r"^(e(xit)?|q(uit)?)$", guess):
            return

        elif search(r"^h(elp)?$", guess):
            print("Your goal is to make the number 24 by using 4 poker cards (numbers from 1 to 13 inclusive)")
            print(f"and the four basic arithmetic operators ({', '.join(operators.keys())}), plus brackets.")
            print("Note that some combinations may not have solutions, so don't worry if you need to restart, but try your best!")
            print("Commands:")
            print("\t backspace - undo the last number or operator you entered")
            print("\t exit - quit the game")
            print("\t help - show this command")
            print("\t restart - restart the game with new cards")
            print("You may also simply type the first character of any of these commands.")

        elif search(r"^r(estart)?$", guess):
            return game(False)

        elif expected == "a number":
            if guess == "(": # Can only accept open bracket when a number is expected (i.e. after an operator, not a number)
                expr += guess
                depth += 1

            elif search(r"^\d+$", guess):
                if guess in cards:
                    expr += guess
                    cards.remove(guess)
                    expected = "an operator" # An operator always follows a number

                    if len(cards) == 0: # All four cards have been used
                        expr += ")" * depth # Pair missing brackets

                        # DANGER DANGER DANGER! We are only using *eval* here because we have tested to ensure that all input 
                        # is standard math equations. Otherwise *eval* can be used to do some very bad things!
                        try:
                            result = eval(expr)
                        except ZeroDivisionError:
                            print("Error: division by zero. Try again!")
                            return game(False, cards=og_cards)
                        
                        if result == 24:
                            if get_yes_no(f"Congratulations! Your solution, {expr}, works. Play again (yes or no)? "):
                                return game(False)
                            else:
                                clear()
                                return
                        else:
                            if get_yes_no(f"Aww, that ({result}) is not the right answer. Play again (yes or no)? "):
                                return game(False, cards=og_cards)
                            else:
                                clear()
                                return

                else:
                    print("That is not one of your cards!")

            else:
                print(f"That was not a valid input. Please enter {'one of the numbers ' + ', '.join(map(str, cards)) if expected == 'a number' else 'one of the operators (+, -, *, /, brackets)'}.")

        # Can only enter close bracket if there is an unpaired open bracket and the expression ends with a number
        elif guess == ")" and depth > 0 and search(r"\d+$", expr): 
            expr += guess
            depth -= 1

        elif expected == "an operator" and guess in operators:
            expr += guess
            expected = "a number" # A number (or open bracket) always follows an operator

        else:
            print(f"That was not a valid input. Please enter {'one of the numbers ' + ', '.join(map(str, cards)) if expected == 'a number' else 'one of the operators (+, -, *, /, brackets)'}.")

def get_num(prompt):
    while True: # We loop until a user gives us a floatable value
        try:
            x = float(input(prompt))
            return x
        except ValueError:
            print("Please enter a valid number.")

# Using a sledgehammer to crack a nut, but it works
def get_yes_no(prompt):
    temp = input(prompt).strip().lower()
    while True:
        if search(r"^y(es)?$", temp):
            return True
        elif search(r"^no?$", temp):
            return False
        
        temp = input("Please enter y(es) or n(o). ").strip()

def main():
    clear()
    print("Welcome to the TI 150.")
    while True:
        op = input(f"Please enter an operator ({', '.join(operators.keys())}), \"game\", or \"exit\": ")

        if op == "exit":
            break

        elif op == "game":
            game(True) # "True" indicates that the user is entering a new game

        elif op in operators:
            # We get two numbers from the user
            a = get_num("Enter first number: ")
            b = get_num("Enter second number: ")

            # Wrapping this in a try/except to catch division by zero
            try:
                result = operators[op](a, b)
                if isinstance(result, float) and result.is_integer():
                    result = int(result) # This strips the decimal off floats that are actually integers
                print(f"Thank you. Your answer is: {result}")
            except ZeroDivisionError:
                print("Error: division by zero")

        else:
            print("Sorry, that is not a valid operator.")

        print() # Newline after each command
    print("Thank you for using the TI 150. I hope you enjoyed it! - from Alexander Cai.\n")
            
if __name__ == "__main__":
    main()