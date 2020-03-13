require "console_splash"
require "colorize"

# --- FUNCTIONS --- #
# Produces a new randomised game board
def get_board(width, height)
  board = Array.new(height) { Array.new(width, '') }
  (0..height - 1).each do |i|
    (0..width - 1).each do |j|
      board[i][j] = initialise_board
    end
  end
  return board
end

# Initialises each cell of the new game board
def initialise_board()
  num = rand(6)
  if num == 0 then
    return :red
  elsif num == 1 then
    return :blue
  elsif num == 2 then
    return :green
  elsif num == 3 then
    return :yellow
  elsif num == 4 then
    return :cyan
  else
    return :magenta
  end
end

# Updates the array that determines which cells are part of the players group
def update_progress_board(board, progressBoard, width, height)
  (0..height - 1).each do |i|
    (0..width - 1).each do |j|
      checkUp = true
      checkDown = true
      checkLeft = true
      checkRight = true
      #Checks the neighbours exist and arent out of the bounds of the array
      if i+1 >= height then
        checkDown = false
      end
      if i-1 < 0 then
        checkUp = false
      end
      if j+1 >= width then
        checkRight = false
      end
      if j-1 < 0 then
        checkLeft = false
      end
      if progressBoard[i][j] == 1 then
        if checkDown && board[i+1][j] == board[0][0] then
          progressBoard[i+1][j] = 1
        end
        if checkUp && board[i-1][j] == board[0][0] then
          progressBoard[i-1][j] = 1
        end
        if checkRight && board[i][j+1] == board[0][0] then
          progressBoard[i][j+1] = 1
        end
        if checkLeft && board[i][j-1] == board[0][0] then
          progressBoard[i][j-1] = 1
        end
      end
    end
  end
end

# Gets an input colour from the user
def get_colour_input()
  print "Choose a colour: "
  colour = gets.chomp.downcase
  return colour
end

#Updates the squares on the board from the progress board based on a user input
def update_game_board(board, progressBoard, width, height, colour)
  (0..height - 1).each do |i|
    (0..width - 1).each do |j|
      if progressBoard[i][j] == 1 then
        if colour == "r" then
          board[i][j] = :red
        elsif colour == "b" then
          board[i][j] = :blue
        elsif colour == "g" then
          board[i][j] = :green
        elsif colour == "y" then
          board[i][j] = :yellow
        elsif colour == "c" then
          board[i][j] = :cyan
        elsif colour == "m" then
          board[i][j] = :magenta
        end
      end
    end
  end
end

# Checks to see if the game is complete by comparing all cells to the top left cell
def check_win(gameBoard, win, width, height, turns)
  count = 0
  (0..height - 1).each do |i|
    (0..width - 1).each do |j|
      if gameBoard[i][j] != gameBoard[0][0] then
        count += 1
      end
    end
  end
  if count == 0 then
    return true
  end
end
      
# Displays the game board and relevant information
def display_board(board, turns, width, height)
  sameColourSq = 0.0;
  board.each do |h|
    h.each do |w|
      print "  ".colorize( :background => w)
    end
    puts
  end
  puts "Number of turns: " + turns.to_s
  board.each do |h|
    h.each do |w|
      if w == board[0][0] then
        sameColourSq += 1.0
      end
    end
  end
  totalSq = width * height
  percentCover = ((sameColourSq / totalSq ) * 100).round
  puts "Current completion: " + percentCover.to_s + "%"
end

#Updates the width of the game board  
def board_width(width)
  print "CURRENT WIDTH: " + width.to_s + " NEW WIDTH: "
  width = gets.chomp.to_i
  return width;
end
    
#Updates the height of the game board  
def board_height(height)
  print "CURRENT HEIGHT: " + height.to_s + " NEW HEIGHT: "
  height = gets.chomp.to_i
  return height;
end
  
#Displays the main menu of the game
def main_menu (gamesPlayed, bestScore)
  puts "Main Menu:"
  puts "s = start a new game"
  puts "c = change game size"
  puts "q = Quit"
  if gamesPlayed == 0 then
    puts "No games played yet"
  else
    puts "Best game: " + bestScore.to_s + " turns"
  end
  print "Please enter your choice: "
end
  
# --- MAIN PROGRAM --- #
# Welcome screen
screen = ConsoleSplash.new(15, 40)
screen.write_horizontal_pattern("*")
screen.write_vertical_pattern("*")
screen.write_header("Flood It", "Robert Dennison", "1.0")
screen.write_center(-3, "Press 'enter' to continue")
screen.splash
puts
gets

# Initialises some values
width = 14
height = 9
gamesPlayed = 0
bestScore = 1000 #large number as the best score is the lowest number of moves
quit = false

# Loop the program, only ends when user decides to quit
while !quit do
  main_menu(gamesPlayed, bestScore)
    input = gets.chomp.downcase
  if input == 'c' then #change board dimensions
    width = board_width(width)
    height = board_height(height)
  elsif input == 'q' then #quits the program
    quit = true
  elsif input == 's' then #starts a game
    gameBoard = get_board(width, height)
    progressBoard = Array.new(height) { Array.new(width, '0')}
    progressBoard[0][0] = 1 #The top left cell added to the player controlled group
    turns = 0
    win = false
    # Loop the game, only exits when the user has won or decides to quit
    while !win do
      display_board(gameBoard, turns, width, height)
      # - This section ensures all cells next to the player group become part of the group if they are the same colour - #
      if width >= height then
        (0..width).each do |i|
          update_progress_board(gameBoard, progressBoard, width, height)
        end
      else
        (0..height).each do |i|
          update_progress_board(gameBoard, progressBoard, width, height)
        end
      end
      # - #
      colour = get_colour_input
      if colour == "q" then #allows the user to quit mid game, return to menu
        break
      else
        update_game_board(gameBoard, progressBoard, width, height, colour)
      end
      win = check_win(gameBoard, win, width, height, turns)
      turns += 1
    end
    #Only updates game stats if the game is won, not if it has been quit
    if win
      display_board(gameBoard, turns, width, height) #When the game is won, display the board one more time in its complete state
      puts "Game complete!"
      puts "You have won after " + turns.to_s + " turns!"
      gets
      bestScore = turns
      gamesPlayed += 1
    end
  end
end
