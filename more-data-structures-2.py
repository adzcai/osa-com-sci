from random import randint

nums = sorted(randint(0, 99) for _ in range(10))
print(f"Numbers: {', '.join(map(str, nums))}")

avg = sum(nums) / len(nums)
print(f"Average: {avg}")

lower, higher = [], []
for i in nums:
  if i <= avg:
    lower.append(i)
  elif i > avg:
    higher.append(i)
  # The assignment didn't specify what to do if the number equalled the average, so I changed "less than" to "less than or equal to"

print(f"Values lower than or equal to the average: {', '.join(map(str, lower))}")
print(f"Values higher than the average: {', '.join(map(str, higher))}")
