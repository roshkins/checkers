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
      res <<  row_to_s(row) * " | " << "\n--------------------------------\n"
    end
    res
  end

  def row_to_s (row)
    row.map do |cell|
       cell ? cell : " "
    end
  end

  def dup
    b = Board.new
      @board.each do |row|
      row.each do |cell|
        Piece.new(cell.location, b, cell.color) if cell
        nil if !cell
      end
    end
    b
  end

  private

  def setup_pieces
    4.times do |col|
      2.times do |row|
        Piece.new([col * 2 + 1, row * 2], self, :red)
        Piece.new([col * 2, 7 - (row * 2)], self, :black)
      end
      Piece.new([col * 2 + 1, 6], self, :black)
      Piece.new([col * 2, 1], self, :red)
    end
  end



end

class Piece

  attr_accessor :king
  attr_reader :color, :location

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
        new_locs([[-2, 2], [2, 2]] + [[-2, -2], [2, -2]], @location)
    else
      case @color
      when :red
        # when red move down board
        # check spots up and left and up and right

          new_locs([[-2, 2], [2, 2]], @location)
      when :black
          new_locs([[-2, -2], [2, -2]], @location)
      else
        raise "@color has invalid color"
      end
    end
  end


  def perform_slide(new_pos)
    possible_moves = slide_moves
    raise InvalidMoveError.new("Not a valid move.")\
    unless possible_moves.include?(new_pos)
    self.location = new_pos
  end

  def perform_jump(new_pos)
    possible_moves = jump_moves
    #check_pos calculates the position between the possible jump place
    check_pos = \
    [(new_pos.first - @location.first) / 2 + @location.first,\
     (new_pos.last  - @location.last)  / 2 + @location.last]


    raise InvalidMoveError.new("Not a valid move.")\
    unless possible_moves.include?(new_pos) && @board[*check_pos]
    @board[*check_pos] = nil
    self.location = new_pos
  end




  def perform_moves(move_seq)
    if valid_move_seq?(move_seq)
      perform_moves!(move_seq)
    else
      raise InvalidMoveError.new("Not even close to a valid move.")
    end
  end



  private
  def perform_moves!(move_sequence)
    move_sequence.each do |move|
      begin
        perform_slide(move)
      rescue InvalidMoveError
        perform_jump(move)
      end
    end
  end

  def valid_move_seq?(move_sequence)
    duped_board = @board.dup
    begin
      duped_board[*@location].perform_moves!(move_sequence)
    rescue InvalidMoveError
      return false
    else
      return true
    end
  end

  def new_locs(relative_moves, position)

    return relative_moves.map do |rel_move|
      rel_move.map.with_index { |itm, idx| @location[idx] + itm }
    end.select do |itm|
          itm.all? { |loc| loc >= 0 && loc < 8 } &&
          @board[*itm].nil?
        end
  end

  def location=(loc)
    @location && @board[*@location] = nil
    @board[*loc] = self
    @location = loc
  end

end

class InvalidMoveError < RuntimeError
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  puts b
  puts
  # b[1, 2].perform_slide([2, 3])
  # b[2, 3].perform_slide([3, 4])
  b[1, 2].perform_moves([[2, 3], [3, 4]])


  puts b.dup
  p b[2, 5].jump_moves
  b[2, 5].perform_jump([4, 3])
  puts b
end