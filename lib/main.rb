# encoding: UTF-8
require 'debugger'
require 'colorize'

class Checkers
  def initialize
    @board = Board.new

  end

  def play
    puts "Welcome to Rashi's Rocking Checkers Game"
    puts
    puts "Para espanol, oprima el dos"
    puts "Too late."

    loop do
      puts @board
      begin
        from_pt = ask_for_pts("Where from? enter an ordered pair, ex: 07")
        to_pts  = ask_for_pts(\
        "Where to? Enter as many moves as you like, separated by spaces")
        @board[*from_pt[0]].perform_moves(to_pts)
      rescue RuntimeError => e
        puts "Error: #{e.message}"
        retry
      end

    end
  end

  def ask_for_pts(prompt_str)
    print "#{prompt_str} "
    gets.split.map{ |str| str.match(/\D*(\d)\D*(\d)\D*/)[1..2].map(&:to_i) }
    raise ""
  end

end


class Board
  include Enumerable
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
    res << "  " + (0..7).to_a * "   " + "\n"
    @board.each_with_index do |row, idx|
      res << "#{idx} " << row_to_s(row) * " | "\
       << "\n--------------------------------\n"
    end
    res << "\n"
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

  def each
    @board.each do |row|
      row.each do |cell|

        yield(cell)
      end
    end
  end

  def jump_pos_available?
    self.any? do |item|
      (item) ? item.jump_pos_available? : false
      end
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
    check_king
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
    check_king
  end

  def check_king
    if (@color == :black && @location.last == 0) || \
       (@color == :white && @location.last == 7)
       @king = true
    end
  end


  def perform_moves(move_seq)
    if valid_move_seq?(move_seq)
      perform_moves!(move_seq)
    else
      raise InvalidMoveError.new("Not even close to a valid move.")
    end
  end

  def jump_pos_available?

    possible_moves = jump_moves
    # debugger if possible_moves.length > 0
    possible_moves.map! do |move|
      check_pos = \
      [(move.first - @location.first) / 2 + @location.first,\
       (move.last  - @location.last)  / 2 + @location.last]
       if @board[*check_pos] && @board[*check_pos].color != @color
         move
       else
         nil
       end
    end
    debugger if possible_moves.compact.length > 0
    possible_moves.compact.length > 0
  end

  protected
  def perform_moves!(move_sequence)
    move_sequence.each do |move|
      unless @board.jump_pos_available?
        begin
          perform_slide(move)
        rescue InvalidMoveError
          perform_jump(move)
        end
      else

        perform_jump(move)
      end
    end
  end



  private
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

  Checkers.new.play
end
