class Play

  attr_accessor :board, :size, :score, :gameover

  MOVES = {
    'w' => 3,
    's' => 1,
    'a' => 0,
    'd' => 2
  }
  SEEDS = [2,4]

  def initialize(size = 4)
    @board = Array.new(size) { Array.new(size,0) }
    @size = size
    @score = 0
    @gameover = false

    spawn_new
    spawn_new
  end

  # To set the state of the game when getting info from Redis
  def main_setter(board, score, gameover)
    @board = board
    @size = 4
    @score = score
    @gameover = gameover
  end

  def rotate!(n=1)
    @board = (0..@size-1).map {|i| @board.map{|row| row[i] }.reverse }
  end

  def slide
    moves = 0
    # Collapse zeroes
    (0...@size).each do|row|
     (0...@size-1).each do|col|
      while @board[row][col] == 0 && @board[row][col+1..@size-1].max > 0
        @board[row][col...@size-1] = @board[row][col+1..@size-1] + [0]
        moves += 1
      end
    end
  end
    # Collapse like cells
    (0...@size).each do|row|
      (0...@size-1).each do|col|
        if @board[row][col] != 0 && @board[row][col] == @board[row][col+1]
          @board[row][col..@size-1] = @board[row][col+1..@size-1] + [0]
          @board[row][col] *= 2
          @score += @board[row][col]
          moves += 1
        end
      end
    end

    return moves
  end

  def game_over?
    if @board.flatten.include?(0)
      @gameover = false
      return @gameover
    end

    @gameover = true
    4.times do
      @board.each do|row|
        row.each_cons(2) do|nums|
          @gameover = false if nums.first == nums.last
        end
      end
      rotate!
    end

    return @gameover
  end

  def move(char)
    m = MOVES[char]
    @gameover = game_over?
    return 0 if m.nil?
    if !@gameover
      m.times { rotate! }
      moves = slide
      (4-m).times { rotate! }
      spawn_new if moves != 0
      return moves
    else
      return @gameover
    end
  end

  def empty_cells
    @board.map.with_index do|row, rowidx|
      row.map.with_index do|num, colidx|
        [rowidx, colidx, num]
      end
    end.flatten(1).find_all{|cell| cell[2] == 0}
  end

  def spawn_new
    empty = empty_cells
    cell = empty.sample(1).flatten
    @board[cell[0]][cell[1]] = SEEDS.sample(1).first
  end
end