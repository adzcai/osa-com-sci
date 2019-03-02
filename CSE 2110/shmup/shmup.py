# Shmup game
# Based on http://kidscancode.org/lessons/
# Frozen Jam by tgfcoder <https://twitter.com/tgfcoder> licensed under CC-BY-3
# Art from Kenney.nl
# Explosions: http://kidscancode.org/blog/img/Explosions_kenney.zip
# 

# ======================================== IMPORT MODULES ========================================
import math, pygame, random, re, sys
from numpy.random import choice
from os import path, listdir
from pygame.locals import *

# ======================================== DEFINE CONSTANTS ========================================
img_dir = path.join(path.dirname(__file__), 'img')
snd_dir = path.join(path.dirname(__file__), 'snd')

font_name = pygame.font.match_font('arial')

WIDTH = 480
HEIGHT = 600
FPS = 60
POWERUP_TIME = 5000
NUM_STARTING_MOBS = 5

# define colors
WHITE  = (255, 255, 255)
BLACK  = (  0,   0,   0)
RED    = (255,   0,   0)
GREEN  = (  0, 255,   0)
BLUE   = (  0,   0, 255)
YELLOW = (255, 255,   0)

allow_spawning = True

def init():
    global screen, clock
    pygame.init()
    pygame.mixer.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Zero Hour - Alexander Cai")
    clock = pygame.time.Clock()

def load_resources():
    # ======================================== LOAD ALL IMAGES ========================================
    global img, background, background_rect, explosion_anim
    # We use a dict comprehension to make a dict holding another dict for each image
    img = {t: load_images(t) for t in ('background', 'damage', 'effects', 'enemies', 'explosions', 'lasers', 'meteors', 'player_ships', 'powerups', 'space_stations', 'ufos', 'ui')}
    _, background, background_rect = get_image('background', 'starfield')

    # Load explosion images
    explosion_anim = {}
    explosion_anim['lg'] = [] # Large meteor
    explosion_anim['sm'] = [] # Small meteor
    explosion_anim['player'] = []
    for i in range(9):
        _, img_lg, _ = get_image('explosions', f'regularExplosion0{i}', (75, 75))
        explosion_anim['lg'].append(img_lg)
        img_sm = pygame.transform.scale(img_lg, (32, 32))
        explosion_anim['sm'].append(img_sm)

        explosion_anim['player'].append(img['explosions'][f'sonicExplosion0{i}'])

    # ======================================== LOAD ALL SOUNDS ========================================
    global shoot_sound, shield_sound, power_sound, expl_sounds, player_die_sound

    # Load all game sounds
    shoot_sound = pygame.mixer.Sound(path.join(snd_dir, 'pew.wav'))
    shield_sound = pygame.mixer.Sound(path.join(snd_dir, 'pow4.wav'))
    power_sound = pygame.mixer.Sound(path.join(snd_dir, 'pow5.wav'))
    expl_sounds = []
    for snd in ['expl3.wav', 'expl6.wav']:
        expl_sounds.append(pygame.mixer.Sound(path.join(snd_dir, snd)))
    player_die_sound = pygame.mixer.Sound(path.join(snd_dir, 'rumble1.ogg'))

    # Load all music
    pygame.mixer.music.load(path.join(snd_dir, 'tgfcoder-FrozenJam-SeamlessLoop.ogg'))
    pygame.mixer.music.set_volume(0.4)
    pygame.mixer.music.play(loops=-1) # Loop music forever

def draw_text(surf, text, size, x, y):
    """Draws text to :surf: with a given font size."""
    font = pygame.font.Font(font_name, size)
    text_surface = font.render(text, True, WHITE)
    text_rect = text_surface.get_rect()
    text_rect.midtop = (x, y)
    surf.blit(text_surface, text_rect)

def newmob(t):
    """Creates a new mob and adds it to the groups."""
    if allow_spawning:
        m = Mob(t)
        all_sprites.add(m)
        mobs.add(m)

def draw_health_bar(surf, x, y, pct):
    """Draws the player's health bar at (x, y)."""
    if pct < 0:
        pct = 0
    BAR_LENGTH = 100
    BAR_HEIGHT = 10
    fill = (pct / 100) * BAR_LENGTH
    outline_rect = pygame.Rect(x, y, BAR_LENGTH, BAR_HEIGHT)
    fill_rect = pygame.Rect(x, y, fill, BAR_HEIGHT)
    pygame.draw.rect(surf, GREEN, fill_rect)
    pygame.draw.rect(surf, WHITE, outline_rect, 2)

def draw_lives(surf, x, y, lives, img):
    """Draw the player's lives, usually as mini ship images in the top right."""
    for i in range(lives):
        img_rect = img.get_rect()
        img_rect.x = x + 30 * i
        img_rect.y = y
        surf.blit(img, img_rect)

class Player(pygame.sprite.Sprite):
    """Stores information about the player."""
    size = (50, 38)
    mini_size = (25, 19)
    MAX_HP = 100
    ACCEL_SPEED = 1
    MAX_SPEED = 8
    DEATH_LENGTH = 1000
    def __init__(self, t):
        pygame.sprite.Sprite.__init__(self)

        self.type, self.image_orig, self.rect = get_image('player_ships', t, Player.size)
        self.image = self.image_orig.copy()
        _, self.mini_img, _ = get_image('ui', t.replace('Ship', 'Life'), Player.mini_size)
        self.color = self.type.split('_')[1]
        if self.color == 'orange':
            self.color = 'red'

        self.rect = self.image.get_rect()
        self.rect.centerx = WIDTH / 2
        self.rect.bottom = HEIGHT - 10
        self.radius = 20

        self.status = 'controlled'

        self.speedx = 0
        self.speedy = 0
        self.accelx = 0

        self.hp = Player.MAX_HP
        self.lives = 3
        self.score = 0

        self.numshots = 1
        self.damage = 10
        self.laser = 1

        self.shoot_delay = 250
        self.last_shot = pygame.time.get_ticks()
        self.hide_timer = pygame.time.get_ticks()
        self.powerups = {}

    def update(self):
        """
        We check if powerups should still be active or if it should still be hidden,
        and then receive user input.
        """
        # timeout for powerups
        expired = []
        for pwrup, pwrup_time in self.powerups.items():
            if pygame.time.get_ticks() - pwrup_time > POWERUP_TIME:
                if pwrup == 'speed':
                    self.shoot_delay *= 2
                    expired.append(pwrup)
        for e in expired:
            del self.powerups[e]

        # check if it has been dead long enough
        if self.status == 'dead' and pygame.time.get_ticks() - self.hide_timer > Player.DEATH_LENGTH:
            self.status = 'controlled'
            self.rect.centerx = WIDTH / 2
            self.rect.bottom = HEIGHT - 10

        if self.status == 'controlled':
            self.move()
        elif self.status == 'landing': # Makes the player landing more tricky by using acceleration
            # Reset acceleration
            keystate = pygame.key.get_pressed()
            self.accelx = 0
            if keystate[K_LEFT]:
                self.accelx = -Player.ACCEL_SPEED
            if keystate[K_RIGHT]:
                self.accelx = Player.ACCEL_SPEED
            self.speedx += self.accelx
            self.speedy = 2

            # Test the player remains below the max speed
            vec = pygame.math.Vector2(self.speedx, self.speedy)
            if vec.length() >= Player.MAX_SPEED:
                vec.scale_to_length(Player.MAX_SPEED)
                self.speedx = vec.x
                self.speedy = vec.y
        
        self.rect.x += self.speedx
        self.rect.y += self.speedy

        # Check bounds
        if self.rect.top < 0:
            self.rect.top = 0
        if self.rect.bottom > HEIGHT:
            self.rect.bottom = HEIGHT
        if self.rect.left < 0:
            self.rect.left = 0
        if self.rect.right > WIDTH:
            self.rect.right = WIDTH

    def move(self):
        # Move left or right based on the arrow keys
        keystate = pygame.key.get_pressed()
        self.speedx = 0
        self.speedy = 0
        if keystate[K_UP]:
            self.speedy = -Player.MAX_SPEED
        if keystate[K_DOWN]:
            self.speedy = Player.MAX_SPEED
        if keystate[K_LEFT]:
            self.speedx = -Player.MAX_SPEED
        if keystate[K_RIGHT]:
            self.speedx = Player.MAX_SPEED
        if keystate[K_SPACE] and self.status == 'controlled':
            self.shoot()

    def powerup(self, p_type):
        if p_type == 'gun':
            self.numshots += 1
            if self.numshots == 4:
                self.numshots = 1
                self.damage += 30
                self.laser += 1
                if self.laser > 16:
                    self.laser = 16
                    self.numshots = 3
            power_sound.play()

        if p_type == 'shield':
            self.hp += random.randrange(10, 30)
            shield_sound.play()
            if self.hp >= 100:
                self.hp = 100

        if p_type == 'speed':
            if 'speed' not in self.powerups: # If the player does not already have this powerup active
                self.shoot_delay //= 2
                power_sound.play()
            self.powerups['speed'] = pygame.time.get_ticks()

    def shoot(self):
        now = pygame.time.get_ticks()
        if now - self.last_shot > self.shoot_delay:
            bullet_pos = {
                1: [self.rect.centerx],
                2: [self.rect.left, self.rect.right],
                3: [self.rect.left, self.rect.centerx, self.rect.right]
            }
            self.last_shot = now
            for pos in bullet_pos[self.numshots]:
                bullet = Bullet(pos, self.rect.centery, self.color, self.laser)
                all_sprites.add(bullet)
                bullets.add(bullet)
            shoot_sound.play()

    def die(self):
        """Hides the player temporarily."""
        self.status = 'dead'
        self.lives -= 1
        self.hp = Player.MAX_HP # Reset HP
        self.hide_timer = pygame.time.get_ticks()
        self.rect.center = (WIDTH / 2, HEIGHT + 200) # Put the player offscreen

class Mob(pygame.sprite.Sprite):
    """
    Stores information about a non-player game entity, usually a meteorite.
    :param t: the type of the mob (meteor, ufo).
    """
    def __init__(self, t):
        pygame.sprite.Sprite.__init__(self)

        if t == 'random': # We generate a random mob
            if random.random() > 0.25:
                self.__init__('meteor')
            else:
                self.__init__('ufo')
            return
        
        self.type = t
        self.image_orig = random_image(self.type + 's')
        self.image = self.image_orig.copy()

        self.rect = self.image.get_rect()
        self.radius = int(self.rect.width * .85 / 2)
        # We spawn the mob somewhere above the screen
        self.rect.x = random.randrange(WIDTH - self.rect.width)
        self.rect.bottom = random.randrange(-80, -20)

        self.hp = self.radius
        self.damage = math.sqrt(self.radius) * 5
        self.powerup_chance = self.radius / 100 # A hacked value that seems to work

        self.speedy = random.randrange(1, 8)
        self.speedx = random.randrange(-3, 3)

        self.rot = 0 # for rotation
        self.rot_speed = random.randrange(-8, 8)

        self.last_update = pygame.time.get_ticks()
        self.new_mob_on_death = True

        if self.type == 'ufo':
            self.last_shot = pygame.time.get_ticks()
            self.shoot_delay = random.randrange(700, 1000)
            self.speedy = random.randrange(2, 4)
            self.offset = random.randrange(0, HEIGHT)
        elif self.type == 'laser':
            self.speedy = random.randrange(5, 10)
            self.damage = 10
            self.new_mob_on_death = False

    def rotate(self):
        now = pygame.time.get_ticks()
        if now - self.last_update > 50:
            self.last_update = now
            self.rot = (self.rot + self.rot_speed) % 360
            new_image = pygame.transform.rotate(self.image_orig, self.rot)
            old_center = self.rect.center
            self.image = new_image
            self.rect = self.image.get_rect()
            self.rect.center = old_center

    def shoot(self):
        now = pygame.time.get_ticks()
        if now - self.last_shot > self.shoot_delay:
            self.last_shot = now
            laser = Mob('laser')
            laser.rect.midtop = self.rect.midtop
            all_sprites.add(laser)
            mobs.add(laser)
            shoot_sound.play()

    def update(self):
        if self.type in ('meteor', 'ufo'):
            self.rotate()

        self.rect.y += self.speedy
        if self.type is 'ufo':
            self.rect.centerx = WIDTH / 4 * math.sin((10 / HEIGHT) * (self.rect.y + self.offset)) +  WIDTH / 2
            self.shoot()
        else:
            self.rect.x += self.speedx

        if self.rect.top > HEIGHT + 10 or self.rect.left < -100 or self.rect.right > WIDTH + 100:
            if self.new_mob_on_death:
                newmob('random')
            self.kill()

class Bullet(pygame.sprite.Sprite):
    """Stores information about a player-fired projectile."""
    def __init__(self, x, y, color, damage):
        pygame.sprite.Sprite.__init__(self)
        self.image = img['lasers'][f'laser{color.capitalize()}{damage:02d}']
        self.rect = self.image.get_rect()
        self.rect.bottom = y
        self.rect.centerx = x
        self.speedy = -10

    def update(self):
        self.rect.y += self.speedy
        # kill if it moves off the top of the screen
        if self.rect.bottom < 0:
            self.kill()

class Pow(pygame.sprite.Sprite):
    """Stores information about a powerup."""
    powerup_to_img = {
        'gun': 'pill_red',
        'shield': 'shield_gold',
        'speed': 'bolt_gold'
    }
    def __init__(self, center):
        pygame.sprite.Sprite.__init__(self)
        self.type = choice(list(Pow.powerup_to_img.keys()), 1, p=[0.5, 0.3, 0.2]) 
        self.image = img['powerups'][Pow.powerup_to_img[self.type[0]]]
        self.rect = self.image.get_rect()
        self.rect.center = center
        self.speedy = 5

    def update(self):
        self.rect.y += self.speedy
        # kill if it moves off the top of the screen
        if self.rect.top > HEIGHT:
            self.kill()

class Explosion(pygame.sprite.Sprite):
    """Displays a simple explosion animation."""
    def __init__(self, center, size):
        pygame.sprite.Sprite.__init__(self)
        self.size = size
        self.image = explosion_anim[self.size][0]
        self.rect = self.image.get_rect()
        self.rect.center = center
        self.frame = 0
        self.last_update = pygame.time.get_ticks()
        self.frame_rate = 75

    def update(self):
        """Updates the frame if enough time has passed."""
        now = pygame.time.get_ticks()
        if now - self.last_update > self.frame_rate:
            self.last_update = now
            self.frame += 1
            if self.frame == len(explosion_anim[self.size]):
                self.kill()
            else:
                center = self.rect.center
                self.image = explosion_anim[self.size][self.frame]
                self.rect = self.image.get_rect()
                self.rect.center = center
        
class Landing_Pad(pygame.sprite.Sprite):
    size = (150, 251)
    def __init__(self):
        pygame.sprite.Sprite.__init__(self)
        _, self.image, self.rect = get_image('space_stations', 'spaceStation_017', Landing_Pad.size)
        self.rect.midtop = (WIDTH // 2, HEIGHT * 3 // 4)

def get_player_ship():
    """Gets the player to choose which image they want for their ship."""
    ship_names = sorted(img['player_ships'].keys())
    _, _, show_ship = get_image('player_ships', 'playerShip1_blue') # we use an arbitrary rect to get the size
    show_ship.center = (WIDTH / 2, HEIGHT / 2)
    
    index = 0
    while True:
        clock.tick(FPS)
        for event in pygame.event.get():
            check_quit(event)
            if event.type != KEYUP:
                continue
            if event.key == K_DOWN:
                index += 4
            if event.key == K_UP:
                index -= 4
            if event.key == K_LEFT:
                index -= 1
            if event.key == K_RIGHT:
                index += 1
            if event.key == K_RETURN:
                return ship_names[index]

        index %= 12 # We have 12 selections for the player ship image

        screen.blit(img['background']['starfield'], background_rect)
        draw_text(screen, "Zero Hour", 64, WIDTH / 2, HEIGHT / 4)
        draw_text(screen, "by Alexander Cai", 32, WIDTH / 2, HEIGHT * 3 / 8)
        draw_text(screen, "Use the arrow keys to choose your ship", 22, WIDTH / 2, HEIGHT * 3 / 4)
        draw_text(screen, "Press enter to select", 18, WIDTH / 2, HEIGHT * 7 / 8)
        screen.blit(img['player_ships'][ship_names[index]], show_ship)

        pygame.display.update([show_ship])

def show_go_screen():
    """Draws the introduction screen."""
    screen.blit(background, background_rect)
    draw_text(screen, "Zero Hour", 64, WIDTH / 2, HEIGHT / 4)
    draw_text(screen, "by Alexander Cai", 32, WIDTH / 2, HEIGHT * 3 / 8)
    draw_text(screen, "Arrow keys move, Space to fire", 22,
              WIDTH / 2, HEIGHT / 2)
    draw_text(screen, "Press a key to begin", 18, WIDTH / 2, HEIGHT * 3 / 4)
    pygame.display.flip()

    waiting = True
    while waiting:
        clock.tick(FPS)
        for event in pygame.event.get():
            check_quit(event)
            if event.type == KEYUP:
                waiting = False

def check_quit(e):
    # check for closing window
    if e.type == QUIT or e.type == KEYUP and e.key == K_ESCAPE:
        pygame.quit()
        sys.exit()

def load_images(img_type):
    images = {}
    for name in listdir(path.join(img_dir, img_type)): # We loop through the directory img/img_type
        if name.endswith('.png'):
            img = pygame.image.load(path.join(img_dir, img_type, name)).convert()
            img.set_colorkey(BLACK)
            images[name[:-4]] = img
    return images

def random_image(img_type):
    return random.choice(list(img[img_type].values()))

def get_image(img_type, img_name, scale=None):
    image = img[img_type][img_name]
    if scale is not None:
        image = pygame.transform.scale(image, scale)
    return img_name, image, image.get_rect()

def level_over(player):
    global all_sprites, mobs, bullets, enemy_bullets, powerups, allow_spawning, clock
    allow_spawning = False

    destination = (WIDTH // 2, HEIGHT // 6)

    player.status = 'rising'
    player.speedx = 0
    player.speedy = 0
    rising = True
    while rising:
        clock.tick(FPS)

        for event in pygame.event.get():
            if event.type == QUIT:
                pygame.quit()
                sys.exit()

        all_sprites.update()
        
        if player.rect.midtop == destination:
            rising = False
        else:
            if player.rect.centerx < destination[0]:
                player.speedx = 1
            elif player.rect.centerx > destination[0]:
                player.speedx = -1
            else:
                player.speedx = 0
            
            if player.rect.top > destination[1]:
                player.speedy = -1
            elif player.rect.top < destination[1]:
                player.speedy = 1
            else:
                player.speedy = 0

        # Draw / render
        screen.fill(BLACK)
        screen.blit(background, background_rect)
        all_sprites.draw(screen)
        draw_text(screen, str(player.score), 18, WIDTH / 2, 10)
        draw_health_bar(screen, 5, 5, player.hp)
        draw_lives(screen, WIDTH - 100, 5, player.lives, player.mini_img)

        pygame.display.flip()

    pad = Landing_Pad()
    all_sprites.add(pad)
    player.status = 'landing'
    passed = False
    while player.rect.bottom <= pad.rect.top:
        clock.tick(FPS)

        for event in pygame.event.get():
            if event.type == QUIT:
                pygame.quit()
                sys.exit()

        all_sprites.update()

        # Draw / render
        screen.fill(BLACK)
        screen.blit(background, background_rect)
        all_sprites.draw(screen)
        draw_text(screen, str(player.score), 18, WIDTH / 2, 10)
        draw_health_bar(screen, 5, 5, player.hp)
        draw_lives(screen, WIDTH - 100, 5, player.lives, player.mini_img)

        pygame.display.flip()
        
    draw_text(screen, "Game over! Press enter to restart or any key to quit", 24, WIDTH // 2, HEIGHT // 4)
    if pad.rect.left < player.rect.centerx and player.rect.centerx < pad.rect.right:
        player.status = 'ended'
        player.speedx = 0
        player.speedy = 0
        draw_text(screen, "Congrats! + 50 Bonus points", 24, WIDTH // 2, HEIGHT // 2)
    else:
        draw_text(screen, "Oh no! You didn't make it", 24, WIDTH // 2, HEIGHT // 2)
    
    pygame.display.flip()

    waiting = True
    while waiting:
        clock.tick(FPS)
        for event in pygame.event.get():
            if event.type == QUIT or event.type == KEYUP and event.key == K_ESCAPE:
                pygame.quit()
                sys.exit()
            if event.type == KEYUP and event.key == K_RETURN:
                waiting = False

def main():
    player_ship_type = get_player_ship() # Prompts the player to select a ship
    game_over = True
    running = True
    level_ended = False
    level_length = 10000
    while running:
        # If the game is over, we re-create all of the groups and mobs
        if game_over:
            global all_sprites, mobs, bullets, enemy_bullets, powerups
            show_go_screen()
            game_over = False
            all_sprites = pygame.sprite.Group() 
            mobs = pygame.sprite.Group()
            bullets = pygame.sprite.Group()
            powerups = pygame.sprite.Group()
            player = Player(player_ship_type)
            all_sprites.add(player)
            for i in range(NUM_STARTING_MOBS):
                newmob('random')
            start_time = pygame.time.get_ticks()

        if pygame.time.get_ticks() - start_time >= level_length: # The level is over
            running = False 

        # keep loop running at the right speed
        clock.tick(FPS)

        # check if the user is exiting the game
        for e in pygame.event.get():
            check_quit(e)

        # update all the sprites
        all_sprites.update()

        # check to see if a bullet hit a mob, destroying both if they do
        hits = pygame.sprite.groupcollide(mobs, bullets, False, False)
        for hit, projs in hits.items(): # projs - player projectiles
            if hit.type == 'laser': # If the player projectile hits an enemy projectile, they both go through each other
                all_sprites.add(b for b in projs)
                bullets.add(b for b in projs)
                continue

            for b in projs:
                b.kill()
            hit.hp -= player.damage
            if hit.hp <= 0:
                player.score += 50 - hit.radius
                random.choice(expl_sounds).play()
                expl = Explosion(hit.rect.center, 'lg')
                all_sprites.add(expl)
                if hit.new_mob_on_death:
                    newmob('random')
                if random.random() < hit.powerup_chance:
                    pwrup = Pow(hit.rect.center)
                    all_sprites.add(pwrup)
                    powerups.add(pwrup)
                hit.kill()

        # check to see if a mob hit the player
        hits = pygame.sprite.spritecollide(player, mobs, True, pygame.sprite.collide_circle)
        for hit in hits:
            player.hp -= hit.damage 
            if player.hp / Player.MAX_HP <= 0.5:
                _, damage, damage_rect = get_image('damage', f"{player.type.split('_')[0]}_damage1", Player.size)
                player.image.blit(damage, damage_rect)
            
            expl = Explosion(hit.rect.center, 'sm')
            all_sprites.add(expl)
            if hit.new_mob_on_death:
                newmob('random')
            if player.hp <= 0:
                player_die_sound.play()
                death_explosion = Explosion(player.rect.center, 'player')
                all_sprites.add(death_explosion)
                player.die()

        # check to see if player hit a powerup
        hits = pygame.sprite.spritecollide(player, powerups, True)
        for hit in hits:
            player.powerup(hit.type)        

        # if the player died and the explosion has finished playing
        if player.lives == 0 and not death_explosion.alive():
            game_over = True

        # Draw / render
        screen.fill(BLACK)
        screen.blit(background, background_rect)
        all_sprites.draw(screen)
        draw_text(screen, str(player.score), 18, WIDTH / 2, 10)
        draw_health_bar(screen, 5, 5, player.hp)
        draw_lives(screen, WIDTH - 100, 5, player.lives, player.mini_img)

        # *after* drawing everything, flip the display
        pygame.display.flip()

    if level_over(player): # If the player decides to go again
        main()

if __name__ == "__main__":
    init()
    load_resources()
    main()