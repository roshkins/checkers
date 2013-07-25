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

  attr_accessor :king
  attr_reader :color

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

  def slide_moves
    if @king
      new_locs([[-1, 1], [1, 1]] + [[-1, -1], [1, -1]], @location)
    else
      case @color
      when :red
        # when red move down board
        # check spots up and left and up and right
        new_locs([[-1, 1], [1, 1]], @location)
      when :black
        new_locs([[-1, -1], [1, -1]], @location)
      else
        raise "@color has invalid color"
      end
    end
  end

  def jump_moves
    if @king
        new_locs(verify_pieces_exist([[-1, 1], [1, 1]] + [[-1, -1], [1, -1]])
        .map.with_index do |elm, idx|
          [[-2, 2], [2, 2]] + [[-2, -2], [2, -2]][idx]
        end, @location)
    else
      case @color
      when :red
        # when red move down board
        # check spots up and left and up and right

          new_locs(verify_pieces_exist([[-1, 1], [1, 1]])
          .map.with_index do |elm, idx|
            [[-2, 2], [2, 2]][idx]
          end, @location)
      when :black
          new_locs(
          verify_pieces_exist([[-1, -1], [1, -1]]).map.with_index do |elm, idx|
          [[-2, -2], [2, -2]][idx]
          end, @location)
      else
        raise "@color has invalid color"
      end
    end
  end

  def verify_pieces_exist(locations)
    # returns list of locations that exist
    locations.map do |rel_move|
          rel_move.map.with_index { |itm, idx| @location[idx] + itm }
        end.select { |itm| @board[*itm] }
  end

  def location=(loc)
    @location && @board[*@location] = nil
    @board[*loc] = self
    @location = loc
  end


  private

  def new_locs(relative_moves, position)

    return relative_moves.map do |rel_move|
      rel_move.map.with_index { |itm, idx| @location[idx] + itm }
    end.select do |itm|
          itm.all? { |loc| loc >= 0 && loc < 8 } &&
          @board[*itm].nil?
        end
  end


end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  puts b.to_s
  p b[0, 0].slide_moves
  p b[0, 2].slide_moves
  b[0, 2].location = [1, 3]
  puts b
  p b[2, 2].slide_moves
end