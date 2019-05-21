scores = []

while len(scores) != 8: # Loop until we have 8 scores
  print("Please enter a number between 1 to 10.")
  try:
    s = int(input())
    if 0 <= s and s <= 10:
      scores.append(s)
    else:
      print("That was not a valid number.")
  except:
    print("That was not a valid number.")

scores = sorted(scores)

print()
print("=" * 10 + " RESULTS " + "=" * 10)
print(f"Your scores: {', '.join(map(str, scores))}")

# Here, since the array is sorted, we can simply access
# the first and last entries in the list.
highest = scores.pop()
lowest = scores.pop(0)

print(f"Removed scores: {lowest} and {highest}")
print(f"Your average score is {sum(scores) / len(scores)}")
print() # I like having whitespace to reduce clutter
