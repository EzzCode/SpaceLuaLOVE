SpaceLuaLOVE
## Video Demo
[URL HERE]

## Description
SpaceLuaLOVE is a 2D space shooter game developed using Lua and the LÖVE framework. It showcases key aspects of game development, including real-time physics, enemy behaviors, sound management, and an interactive interface.

In SpaceLuaLOVE, players control a spaceship using mouse movement and fire bullets by clicking. The ship navigates through space, avoiding enemies and lasers while collecting points. The game includes background music, sound effects, and dynamic background scaling, ensuring a smooth user experience on different screen sizes.

## Project Structure
- **main.lua**: Entry point of the game. Initializes core elements like the player’s ship, enemies, and UI. Manages the game loop (update and draw functions).
- **assets/**: Contains all graphics and audio files. Spaceship sprites, enemy sprites, and background music are stored here, ensuring modularity.
- **components/**: Holds reusable components, such as buttons and game objects, making the code more modular and maintainable.
- **states/**: Manages game states like the main menu, gameplay, and game over screen. A state machine helps structure the game flow and simplifies transitions.
- **objects/**: Contains core game objects like the spaceship, bullets, and enemies. These objects handle their behavior, movement, and interaction logic.
- **globals.lua**: Holds global variables and configurations accessible across the entire game, such as screen dimensions, colors, and game settings.

## Design Choices
- **Physics-based Ship Movement**: Implemented a physics-based movement system for the spaceship, involving thrust and friction mechanics for realistic and challenging control.
- **Mouse-controlled Aiming**: Opted for mouse-based aiming and shooting, giving players precision in guiding the ship and shooting.
- **Enemy Behavior**: Enemies actively engage the player with laser warnings and movement. The enemy class incorporates timed attacks, adding difficulty.
- **Audio Management**: Includes background music and various sound effects. A system allows multiple sound effects to play simultaneously for a smooth audio experience.

## Future Improvements
- **Additional Levels**: Adding multiple levels with unique enemy types and environmental challenges.
- **Power-ups**: Introducing power-ups like shields or special weapons for more strategic options and enhanced gameplay depth.
- **Improved Enemy AI**: Future iterations could include AI-driven enemy behavior for more dynamic and unpredictable encounters.

## Conclusion
SpaceLuaLOVE is a fun and engaging project that demonstrates my skills in Lua and game development. It highlights the effective use of the LÖVE framework to create a complete gaming experience with physics-based mechanics, intuitive controls, and immersive audiovisual effects. I plan to continue improving the game by adding more features and refining the codebase for performance and scalability.
