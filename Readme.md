## Video Demo

## Table of Contents
1. [Project Overview](#project-overview)
2. [Design Choices](#design-choices)
3. [Installation](#installation)
4. [Project Structure](#project-structure)
5. [Future Improvements](#future-improvements)
6. [Conclusion](#conclusion) 
6. [Credits](#credits)
7. [Images](#images)


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
- **main.lua**: The entry point of the game, managing game initialization and loops.
- **assets/**: Contains all graphics and audio files. Spaceship sprites, enemy sprites, and background music are stored here.
- **components/**: Holds reusable components, such as buttons and game objects, making the code more modular and maintainable.
- **states/**: Manages game states like the main menu, gameplay, and game over screen.
- **objects/**: Contains core game objects like the spaceship, bullets, and enemies. These objects handle their behavior, movement, and interaction logic.
- **globals.lua**: Holds global variables and configurations accessible across the entire game, such as screen dimensions, colors, and game settings.

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
![Menu Screen](path/to/menu_screen.png)

### Game Level
![Game Level](path/to/game_level.png)