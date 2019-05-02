to_filter = [0, 1, 1, 7, 2, 3, 4, 5, 6, 7, 0, 8, 9, 1, 3, 6, 9, 0]

# We could make it into a set to remove duplicates, then convert it back into a list.
# print(list(set(to_filter))) 

# However, if we want to preserve order, here is another method:
new_list = []
for i in to_filter:
  if i not in new_list:
    new_list.append(i)
print(new_list)