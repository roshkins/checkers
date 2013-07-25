# encoding: UTF-8
require 'colorize'
class Board
  def initialize
    @board = Array.new(8) { Array.new(8) { nil } }
    setup_pieces
  end

  def [](x, y)
    @board[y][x]
  end


  def []=(x, y, piece)
    @board[y][x] = piece
  end

  def to_s
    res = ""
    @board.each do |row|
      res << row * " ".white.on_white << "\n"
    end
    res
  end

  private

  def setup_pieces
    4.times do |col|
      2.times do |row|
        Piece.new([col * 2, row * 2], self, :red)
        Piece.new([col * 2, 7 - (row * 2)], self, :black)
      end
      Piece.new([col * 2 + 1, 6], self, :black)
      Piece.new([col * 2 + 1, 1], self, :red)
    end
  end

end

class Piece

  attr_reader :king, :color

  def initialize(location, board, color)
    @king = false
    @board = board
    @color = color
    self.location = location
  end


  def to_s
    case @color
    when :red
      "⬤".red
    when :black
      "⬤".black
    else
      raise "Invalid color in @color in Piece"
    end
  end

  def location=(loc)
    @location && @board[*@location] = nil
    @board[*loc] = self
  end
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  puts b.to_s
end