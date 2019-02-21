def isPrime(n):
    if n <= 1:
        return False

    i = 2
    while i * i <= n: # We only need to check up to the square root
        if n % i == 0:
            return False
        i += 1

    return True

def isPerfect(n):
    divisors = []
    i = 1
    while i * i <= n:
        if n % i == 0:
            divisors += [i, n // i]
        i += 1

    return sum(sorted(divisors)[:-1]) == n

def pascal(nr):
    rows = [[1, 0], [1, 1, 0]]

    if nr == 1:
        return [1, 0]
    elif nr == 2:
        return [1, 1, 0]

    for i in range(3, nr + 1):
        l = [1] + ([None] * (i-2)) + [1, 0]
        for j in range(1, i):
            l[j] = rows[i - 2][j-1] + rows[i-2][j]
    
        rows.append(l)
    
    rows = [r[:-1] for r in rows] # Get rid of the trailing zeroes

    for r in rows:
        print(' '.join(map(str, r))) # For each row, we make each num into a string and join them with spaces
    
    return rows

def numVowels(s):
    return sum(s.count(v) for v in 'aeiou')
