<template>
  <div class="bomberman-game">
    <div class="game-grid">
      <div
        v-for="(row, rowIndex) in grid"
        :key="rowIndex"
        class="row"
      >
        <div
          v-for="(cell, colIndex) in row"
          :key="colIndex"
          :class="cellClass(rowIndex, colIndex)"
        ></div>
      </div>
    </div>
    <div class="controls">
      <p>Use arrow keys to move. Press space to drop a bomb (1 at a time).</p>
    </div>
    <template v-if="gameOver">
      <div class="game-over">
        Game Over! You died.<br />
        <button @click="restartGame">Restart</button>
      </div>
    </template>
    <template v-if="gameWon">
      <div class="game-won">
        Congratulations! You won the game.<br />
        <button @click="restartGame">Play Again</button>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'

const ROWS = 13
const COLS = 15

// 0 = empty, 1 = wall, 2 = destructible block, 3 = power item
const initialGrid = () => {
  const grid = []
  for (let r = 0; r < ROWS; r++) {
    const row = []
    for (let c = 0; c < COLS; c++) {
      if (r === 0 || r === ROWS - 1 || c === 0 || c === COLS - 1) {
        row.push(1) // border wall
      } else if (r % 2 === 0 && c % 2 === 0) {
        row.push(1) // inner wall
      } else if (Math.random() < 0.2) {
        row.push(2) // destructible block
      } else {
        row.push(0) // empty
      }
    }
    grid.push(row)
  }
  // Clear player spawn
  grid[1][1] = 0
  grid[1][2] = 0
  grid[2][1] = 0
  return grid
}

const grid = ref([])
const player = ref({ row: 1, col: 1 })
const bomb = ref(null) // { row, col, timer }
const explosion = ref([]) // Array of { row, col }
const gameOver = ref(false)
const gameWon = ref(false)
const POWER_ITEM = 3
const explosionRange = ref(1)
const powerItemPos = ref(null)
const powerItemVisible = ref(false)
const BOMB_CAPACITY_ITEM = 4
const maxBombs = ref(1)
const activeBombs = ref(0)
const bombCapacityItemPos = ref(null)
const bombCapacityItemVisible = ref(false)

function cellClass(row, col) {
  if (player.value.row === row && player.value.col === col) return 'cell player'
  if (Array.isArray(bomb.value) && bomb.value.some(b => b.row === row && b.col === col)) return 'cell bomb'
  if (bomb.value && !Array.isArray(bomb.value) && bomb.value.row === row && bomb.value.col === col) return 'cell bomb'
  if (explosion.value.some(cell => cell.row === row && cell.col === col)) return 'cell explosion'
  if (powerItemVisible.value && powerItemPos.value && powerItemPos.value.row === row && powerItemPos.value.col === col) return 'cell power-item'
  if (bombCapacityItemVisible.value && bombCapacityItemPos.value && bombCapacityItemPos.value.row === row && bombCapacityItemPos.value.col === col) return 'cell bomb-capacity-item'
  const val = grid.value[row][col]
  if (val === 1) return 'cell wall'
  if (val === 2) return 'cell destructible'
  return 'cell empty'
}

function canMove(row, col) {
  if (grid.value[row][col] !== 0 && !(powerItemVisible.value && powerItemPos.value && powerItemPos.value.row === row && powerItemPos.value.col === col) && !(bombCapacityItemVisible.value && bombCapacityItemPos.value && bombCapacityItemPos.value.row === row && bombCapacityItemPos.value.col === col)) return false
  if (bomb.value && bomb.value.row === row && bomb.value.col === col) return false
  return true
}

function handleKey(e) {
  if (gameOver.value || gameWon.value) return
  let { row, col } = player.value
  let moved = false
  if (e.key === 'ArrowUp' && canMove(row - 1, col)) { row--; moved = true }
  if (e.key === 'ArrowDown' && canMove(row + 1, col)) { row++; moved = true }
  if (e.key === 'ArrowLeft' && canMove(row, col - 1)) { col--; moved = true }
  if (e.key === 'ArrowRight' && canMove(row, col + 1)) { col++; moved = true }
  // Drop bomb with spacebar
  if (e.key === ' ' || e.key === 'Spacebar') {
    if (activeBombs.value < maxBombs.value && !bombAt(player.value.row, player.value.col)) {
      placeBomb(player.value.row, player.value.col)
    }
    return // Don't update player position when dropping bomb
  }
  if (moved) {
    player.value = { row, col }
    // Check for power item collection
    if (powerItemVisible.value && powerItemPos.value && row === powerItemPos.value.row && col === powerItemPos.value.col) {
      explosionRange.value = 2
      powerItemVisible.value = false
      powerItemPos.value = null
    }
    // Check for bomb capacity item collection
    if (bombCapacityItemVisible.value && bombCapacityItemPos.value && row === bombCapacityItemPos.value.row && col === bombCapacityItemPos.value.col) {
      maxBombs.value = 2
      bombCapacityItemVisible.value = false
      bombCapacityItemPos.value = null
    }
  }
}

function bombAt(row, col) {
  if (Array.isArray(bomb.value)) {
    return bomb.value.some(b => b.row === row && b.col === col)
  } else if (bomb.value) {
    return bomb.value.row === row && bomb.value.col === col
  }
  return false
}

function placeBomb(row, col) {
  if (!bomb.value) bomb.value = []
  bomb.value.push({ row, col, timer: setTimeout(() => explodeBomb(row, col), 2000) })
  activeBombs.value++
}

function explodeBomb(row, col) {
  // Remove bomb from array
  if (Array.isArray(bomb.value)) {
    bomb.value = bomb.value.filter(b => !(b.row === row && b.col === col))
  } else {
    bomb.value = null
  }
  activeBombs.value = Math.max(0, activeBombs.value - 1)
  // Explode in cross pattern (up, down, left, right, and center), stopping at unbreakable walls
  const positions = [{ row, col }]
  // Up
  for (let r = row - 1, i = 0; i < explosionRange.value; r--, i++) {
    if (grid.value[r] && grid.value[r][col] === 1) break
    positions.push({ row: r, col })
    if (grid.value[r][col] === 2) break
  }
  // Down
  for (let r = row + 1, i = 0; i < explosionRange.value; r++, i++) {
    if (grid.value[r] && grid.value[r][col] === 1) break
    positions.push({ row: r, col })
    if (grid.value[r][col] === 2) break
  }
  // Left
  for (let c = col - 1, i = 0; i < explosionRange.value; c--, i++) {
    if (grid.value[row] && grid.value[row][c] === 1) break
    positions.push({ row, col: c })
    if (grid.value[row][c] === 2) break
  }
  // Right
  for (let c = col + 1, i = 0; i < explosionRange.value; c++, i++) {
    if (grid.value[row] && grid.value[row][c] === 1) break
    positions.push({ row, col: c })
    if (grid.value[row][c] === 2) break
  }
  explosion.value = positions
  // Check if player is in explosion area
  if (positions.some(pos => pos.row === player.value.row && pos.col === player.value.col)) {
    gameOver.value = true
  }
  for (const pos of positions) {
    if (grid.value[pos.row] && grid.value[pos.row][pos.col] === 2) {
      grid.value[pos.row][pos.col] = 0 // Destroy destructible block
      // Reveal power item if present
      if (powerItemPos.value && pos.row === powerItemPos.value.row && pos.col === powerItemPos.value.col) {
        powerItemVisible.value = true
      }
      // Reveal bomb capacity item if present
      if (bombCapacityItemPos.value && pos.row === bombCapacityItemPos.value.row && pos.col === bombCapacityItemPos.value.col) {
        bombCapacityItemVisible.value = true
      }
    }
  }
  // Check win condition
  if (!grid.value.flat().includes(2)) {
    gameWon.value = true
  }
  setTimeout(() => {
    explosion.value = []
  }, 400)
}

function initialGridWithPower() {
  const grid = initialGrid()
  // Find all destructible block positions
  const destructibles = []
  for (let r = 0; r < ROWS; r++) {
    for (let c = 0; c < COLS; c++) {
      if (grid[r][c] === 2) destructibles.push({ row: r, col: c })
    }
  }
  // Place explosion range power item
  if (destructibles.length > 0) {
    const idx = Math.floor(Math.random() * destructibles.length)
    powerItemPos.value = destructibles[idx]
    // Remove from destructibles so bomb capacity item can't be in the same spot
    destructibles.splice(idx, 1)
  } else {
    powerItemPos.value = null
  }
  // Place bomb capacity power item
  if (destructibles.length > 0) {
    const idx2 = Math.floor(Math.random() * destructibles.length)
    bombCapacityItemPos.value = destructibles[idx2]
  } else {
    bombCapacityItemPos.value = null
  }
  powerItemVisible.value = false
  bombCapacityItemVisible.value = false
  explosionRange.value = 1
  maxBombs.value = 1
  activeBombs.value = 0
  return grid
}

function restartGame() {
  grid.value = initialGridWithPower()
  player.value = { row: 1, col: 1 }
  bomb.value = []
  explosion.value = []
  gameOver.value = false
  gameWon.value = false
  powerItemVisible.value = false
  powerItemPos.value = null
  bombCapacityItemVisible.value = false
  bombCapacityItemPos.value = null
  explosionRange.value = 1
  maxBombs.value = 1
  activeBombs.value = 0
}

onMounted(() => {
  grid.value = initialGridWithPower()
  bomb.value = []
  window.addEventListener('keydown', handleKey)
})
onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKey)
  if (bomb.value && bomb.value.timer) clearTimeout(bomb.value.timer)
})
</script>

<style scoped>
.bomberman-game {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.game-grid {
  display: flex;
  flex-direction: column;
  background: #222;
  border: 4px solid #444;
  margin-bottom: 1rem;
}
.row {
  display: flex;
}
.cell {
  width: 32px;
  height: 32px;
  box-sizing: border-box;
  border: 1px solid #333;
}
.cell.empty {
  background: #444;
}
.cell.wall {
  background: #888;
}
.cell.destructible {
  background: #c96;
}
.cell.player {
  background: #4af;
  border: 2px solid #fff;
}
.cell.bomb {
  background: #222 url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><circle cx="16" cy="18" r="10" fill="black" stroke="white" stroke-width="2"/><rect x="14" y="6" width="4" height="8" fill="gray"/></svg>') center/cover no-repeat;
  border: 2px solid #fff;
}
.cell.explosion {
  background: radial-gradient(circle, #ff0 60%, #f90 100%);
  animation: explosion-flash 0.4s linear;
  border: 2px solid #fff;
}
.cell.power-item {
  background: radial-gradient(circle, #fff 60%, #0ff 100%);
  border: 2px solid #0ff;
  position: relative;
}
.cell.power-item::after {
  content: '💥';
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  font-size: 1.3em;
}
.cell.bomb-capacity-item {
  background: radial-gradient(circle, #fff 60%, #f44 100%);
  border: 2px solid #f44;
  position: relative;
}
.cell.bomb-capacity-item::after {
  content: '💣';
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  font-size: 1.3em;
}
.controls {
  color: #fff;
  font-family: monospace;
}
.controls p {
  margin-top: 0.5em;
}
@keyframes explosion-flash {
  0% { opacity: 1; }
  50% { opacity: 0.7; }
  100% { opacity: 0; }
}
.game-over {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0,0,0,0.85);
  color: #fff;
  font-size: 2rem;
  padding: 2rem 3rem;
  border-radius: 1rem;
  z-index: 10;
  text-align: center;
  font-family: monospace;
}
.game-over button {
  margin-top: 1.5rem;
  font-size: 1.2rem;
  padding: 0.5rem 1.5rem;
  border: none;
  border-radius: 0.5rem;
  background: #4af;
  color: #fff;
  cursor: pointer;
  font-family: monospace;
  transition: background 0.2s;
}
.game-over button:hover {
  background: #238;
}
.game-won {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0,0,0,0.85);
  color: #fff;
  font-size: 2rem;
  padding: 2rem 3rem;
  border-radius: 1rem;
  z-index: 10;
  text-align: center;
  font-family: monospace;
}
.game-won button {
  margin-top: 1.5rem;
  font-size: 1.2rem;
  padding: 0.5rem 1.5rem;
  border: none;
  border-radius: 0.5rem;
  background: #4af;
  color: #fff;
  cursor: pointer;
  font-family: monospace;
  transition: background 0.2s;
}
.game-won button:hover {
  background: #238;
}
</style> 