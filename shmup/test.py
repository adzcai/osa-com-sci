import sys, os, pygame, math

meteors = os.path.join(os.path.dirname(__file__), 'img', sys.argv[1] or 'meteors')
for i in os.listdir(meteors):
    img = pygame.image.load(os.path.join(meteors, i))
    w = img.get_rect().width
    print(f'width:{w}')
    print (f'damage:{math.sqrt(w) * 5}')