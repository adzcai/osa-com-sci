with open ('titles.txt', 'r+') as f:
  print(','.join(f.read().splitlines()))
