class Board
  def initialize
    @board = Array.new(8) { Array.new(8) }
    setup_pieces
  end

  def [](x, y)
    @board[y][x]
  end

  private

  def []=(x, y, piece)
    @board[y][x] = piece
  end

end