# Description: http://classroom.google.com/c/Mjc4NTQ4NDcyOTNa/a/MzIxMjIyNTUyMDZa/details
# Notes: this program uses a lot of regular expressions, which we haven't covered in class
# but I thought were necessary to  write the program as I did.
# To make my code neater, I used python f-strings to quickly format a variable
# into a line

import re
from random import randint

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

# We get 4 random playing card values, from 1 (A) to 13 (K)
def generate_cards():
    cards = []
    for i in range(4): 
        cards.append(str(randint(1, 13)))
    print(f"Your cards: {', '.join(cards)}")
    return cards

def game(first_time):
    # Shorthand for returning out if they don't want to play
    if first_time and not get_yes_no("Welcome to the 24 Game! Would you like to play (yes or no)? "):
        return

    cards = generate_cards()

    expr = ""
    expected = "number"
    depth = 0

    while True:
        if len(expr) > 0:
            print(f"Your current expression: {expr}. ", end="")
        guess = input(f"Please enter a {expected}, \"b(ackspace)\", \"help,\" or \"exit\": ").strip()

        if re.search(r"^(q(uit)?|e(xit)?)$", guess, re.I):
            return

        elif re.search(r"^h(elp)?$", guess, re.I):
            print("\tYour goal is to make the number 24 by using 4 poker cards (numbers from 1 to 13 inclusive)")
            print(f"\tand the four basic arithmetic operators ({', '.join(operators.keys())}), plus brackets.")
            print(f"\tYour numbers are: {', '.join(cards)}")
            print("\tNote that some combinations may not have solutions, so don't worry if you need to restart, but try your best!")

        elif re.search(r"^r(estart)?$", guess, re.I):
            cards = generate_cards()

        elif re.search(r"^(b(ack)?(space)?|u(ndo)?)$", guess, re.I):
            ending_num = re.search(r"(\d+)$", expr) # Ends with a number
            if ending_num:
                expr = expr[:-len(ending_num.string)] # We remove that number off the end
                cards.append(ending_num.string)
                expected = "number"
            else: # We remove the operator at the end
                expr = expr[:-1]
                expected = "operator"

        elif guess == "(": # Can accept open parentheses for number or operator
            expr += guess
            depth += 1

        # Can only enter close bracket if there is an unpaired open bracket and the expression ends with a number
        elif guess == ")" and depth > 0 and re.search(r"\d+$", guess): 
            expr += guess
            depth -= 1

        elif expected == "number":
            if guess not in cards:
                print("That is not one of your cards!")
                continue
            
            expr += guess
            cards.remove(guess)
            expected = "operator" # An operator always follows a number

            if len(cards) == 0: # All four cards have been used
                expr += ")" * depth # Pair missing brackets

                # DANGER DANGER DANGER! We are only using *eval* here because we have tested to ensure that all input 
                # is standard math equations. Otherwise *eval* can be used to do some very bad things!
                result = eval(expr)
                if result == 24 and get_yes_no(f"Congratulations! Your solution, {expr}, works. Play again? ") or get_yes_no(f"Aww, that ({result}) is not the right answer. Play again? "):
                    return game(False)
                else:
                    return

        elif expected == "operator" and guess in operators:
            expr += guess
            expected = "number" # A number (or open bracket) always follows an operator

        else:
            print(f"That was not a valid input. Please enter {'one of the numbers' + ', '.join(map(str, cards)) if expected == 'number' else 'one of the operators (+, -, *, /, brackets)'}.")

def get_num(prompt):
    while True: # We loop until a user gives us a floatable value
        try:
            x = float(input(prompt))
            return x
        except ValueError:
            print("Please enter a valid number.")

# Using a sledgehammer to crack a nut, but it works
def get_yes_no(prompt):
    temp = input(prompt).strip()
    while True:
        if re.search(r"^y(es)?$", temp, flags=re.IGNORECASE):
            return True
        elif re.search(r"^no?$", temp, flags=re.IGNORECASE):
            return False
        
        temp = input("Please enter y(es) or n(o). ").strip()

def main():
    print("Welcome to the TI 150.")
    while True:
        op = input(f"Please enter operator ({', '.join(operators.keys())}), game, or exit: ")
        if op == "exit":
            break

        elif op == "game":
            game(True)

        elif op in operators:
            a = get_num("Enter first number: ")
            b = get_num("Enter second number: ")

            try:
                result = operators[op](a, b)
                if isinstance(result, float) and result.is_integer():
                    result = int(result) # This strips the decimal off floats that are actually integers
                print(f"Thank you. Your answer is: {result}")
            except ZeroDivisionError:
                print("Error: division by zero")

        else:
            print("Sorry, that is not a valid operator.")
    print("Thank you for using the TI 150. I hope you enjoyed it! - from Alexander Cai.")
            
if __name__ == "__main__":
    main()