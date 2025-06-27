# Bomberman Game

A simple Bomberman-inspired browser game built with **Node.js**, **VueJS**, and **Nuxt.js**.

## Game Description

- Navigate a grid-based map, drop bombs to destroy breakable walls, and collect power-ups.
- Avoid bomb explosions and try to clear all breakable walls to win!
- Features:
  - Power-ups to increase bomb explosion area and allow multiple bombs at once.
  - Timer to track your completion time.

## How to Install and Run Locally

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd bomberman
   ```
2. **Install dependencies:**
   ```bash
   npm install
   ```
3. **Run the development server:**
   ```bash
   npm run dev
   ```
4. Open your browser and go to [http://localhost:3000](http://localhost:3000)

## How to Play

- **Move:** Use the arrow keys (↑, ↓, ←, →) to move your character.
- **Drop Bomb:** Press the <kbd>Space</kbd> key to drop a bomb (you can only drop as many bombs as your current power allows).
- **Destroy Walls:** Bombs will destroy breakable (orange) walls in a cross pattern. Unbreakable (gray) walls block explosions.
- **Collect Power-ups:**
  - 💥 (blue/white): Increases your bomb explosion area by 1.
  - 💣 (red/white): Allows you to place one more bomb at the same time.
- **Win:** Destroy all breakable walls to win. Your completion time will be displayed.
- **Lose:** If you are caught in a bomb explosion, you lose the game.
- **Restart:** Use the on-screen button to play again after winning or losing.

Enjoy playing!
