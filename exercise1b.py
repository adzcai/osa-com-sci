n = int(input())

words = [
  'Roses are red',
  'Violets are blue',
  'Computer Science is fun',
  'Python is too'
]

# Since words is an array, we join the lines with spaces to form a long string
# with all of the words separated by spaces, and then we split using spaces to get
# an array of individual words. We then filter this list for all of the words
# with a length longer than n, using a lambda (a brief, anonymous function).

print(list(filter(lambda word: len(word) > n, ' '.join(words).split(' '))))