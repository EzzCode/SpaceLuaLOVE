## Table of Contents
1. [Project Overview](#project-overview)
2. [Design Choices](#design-choices)
3. [Installation](#installation)
4. [Project Structure](#project-structure)
5. [Future Improvements](#future-improvements)
6. [Conclusion](#conclusion) 
6. [Credits](#credits)
7. [Images](#images)
9. [Video Demo](#video-demo)


## Project Overview
In SpaceLuaLOVE, players control a spaceship using mouse movement and fire bullets by clicking. The ship navigates through space, avoiding asteroids and enemy lasers/bullets. The game includes background music, sound effects, and dynamic background.


## Design Choices
- **Physics-based Ship Movement**: Implemented a physics-based movement system for the spaceship, involving acceleration and friction mechanics for realistic and challenging control.
- **Mouse-controlled Aiming**: Opted for mouse-based aiming and shooting, giving players precision in guiding the ship and shooting.
- **Dynamic Background Scaling**: Added parallax effect for the background and scalefactors. Ensures the game fits different screen sizes.
- **Enemy Behavior**: Enemies actively engage the player with laser warnings and movement. The enemy class incorporates timed attacks, adding difficulty.
- **Audio Management**: Includes background music and various sound effects. A system allows multiple sound effects.

## Installation
To play SpaceLuaLOVE, follow these steps:
1. Clone the repository:
    ```bash
    git clone https://github.com/EzzCode/SpaceLuaLOVE.git
    cd SpaceLuaLOVE
    ```
2. Install the [LÖVE framework](https://love2d.org/).
3. Run the game:
    ```bash
    love .
    ```

## Project Structure

### 1. **main.lua**
- This is the entry point of the game. It handles the initialization of the game, loading assets, and setting up the game loop. It coordinates between different game states, such as the main menu, the gameplay itself, and the game over screen.

### 2. **globals.lua**
- Contains global variables and configurations that are accessible throughout the game. This file stores constants such as screen dimensions, game speed, colors, and other essential settings that can be referenced anywhere in the project.

### Folders:

#### **assets/**
This folder contains all of the visual and audio assets for the game:
- **images/**: Contains the spaceship, enemy, background, and other visual elements in the form of sprites.
  - **spaceship.png**: The player's spaceship sprite.
  - **enemy.png**: The enemy ship sprites.
  - **background.png**: The space background used in the game.
  
- **sounds/**: Stores the sound effects and background music used during gameplay.
  - **background_music.ogg**: Background music played during the game.
  - **explosion.wav**: Sound effect triggered when the spaceship is destroyed or an enemy is hit.
  - **laser.wav**: Sound effect played when the spaceship or enemy shoots.

#### **components/**
This folder contains reusable modules that make the game more modular:
- **Button.lua**: Implements a generic button class used in menus or other parts of the UI. It handles user interaction (e.g., clicks) and visual rendering of buttons.
- **GameObject.lua**: Defines a base class for all objects in the game, such as the spaceship, bullets, enemies, etc. This class contains common functionality such as updating position, rendering, and handling collisions.

#### **objects/**
Contains all the game objects (the entities that interact with each other in the game world):
- **Spaceship.lua**: Defines the player’s spaceship, including its movement logic, how it fires bullets, and how it responds to player input (mouse and keyboard).
- **Bullet.lua**: Manages the bullets fired by the player’s ship. It contains logic for movement and interactions, such as collision detection with enemies.
- **Enemy.lua**: Contains the logic for enemy movement and behavior. This includes tracking the player's position and shooting at the player.
  
#### **states/**
Manages different states of the game (e.g., menus, gameplay):
- **MenuState.lua**: Implements the main menu screen where players can start the game or quit. It interacts with the `Button.lua` class for menu selections.
- **GameState.lua**: Handles the gameplay state, managing game progression, score, and player actions. It continuously updates the game world and tracks user input.
- **GameOverState.lua**: Displays the game over screen when the player loses, giving options to restart or quit the game.

## Future Improvements
- **Power-ups**: Introducing power-ups to enhance gameplay.
- **Level Progression**: Implementing multiple levels with increasing difficulty.

## Conclusion
SpaceLuaLOVE is a fun and engaging project that demonstrates my skills in Lua and game development. It highlights the effective use of the LÖVE framework to create a complete gaming experience with physics-based mechanics, intuitive controls, and immersive audiovisual effects. I plan to continue improving the game by adding more features and refining the codebase for performance and scalability.

## Credits
- **LÖVE Framework**: [LÖVE](https://love2d.org/) - For providing an excellent 2D game framework.
- **Art Assets**:
    - Deep-Fold space background generator
    - gameart2d TOP-DOWN SPACE SHOOTER CREATION KIT
    - foozle void environment pack
    - craftpix.net Free Pixel Magic Sprite Effects Pack
- **Music & Sound Effects**: pixabay.com

## Images

### Menu Screen
![Menu Screen](https://github.com/user-attachments/assets/ef832add-7728-4a55-a35e-f7bf3859af65)

### Game Level
![Game Level](https://github.com/user-attachments/assets/aaee1c85-47cc-4136-9d8c-2fea3035706a)

## Video Demo

[![Watch the video](https://img.youtube.com/vi/mMEjM3f-0N0/0.jpg)](https://youtu.be/mMEjM3f-0N0)
