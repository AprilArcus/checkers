require_relative 'piece'

class Board

  def self.setup
    board = Board.new
    board.pieces = [Piece.new(board, [0,0], :white), Piece.new(board, [7,7], :black),
                    Piece.new(board, [2,0], :white), Piece.new(board, [5,7], :black),
                    Piece.new(board, [4,0], :white), Piece.new(board, [3,7], :black),
                    Piece.new(board, [6,0], :white), Piece.new(board, [1,7], :black),
                    Piece.new(board, [1,1], :white), Piece.new(board, [6,6], :black),
                    Piece.new(board, [3,1], :white), Piece.new(board, [4,6], :black),
                    Piece.new(board, [5,1], :white), Piece.new(board, [2,6], :black),
                    Piece.new(board, [7,1], :white), Piece.new(board, [0,6], :black),
                    Piece.new(board, [0,2], :white), Piece.new(board, [7,5], :black),
                    Piece.new(board, [2,2], :white), Piece.new(board, [5,5], :black),
                    Piece.new(board, [4,2], :white), Piece.new(board, [3,5], :black),
                    Piece.new(board, [6,2], :white), Piece.new(board, [1,5], :black)]
    board.rehash
    board
  end

  attr_accessor :pieces, :positions_hash

  def [](pos)
    pos = self.class.parse_string(pos) if pos.is_a?(String)
    @positions_hash[pos]
  end

  def to_s
    output = "\n  a b c d e f g h\n"
    7.downto(0) do |rank|
      output += "#{rank + 1} "
      0.upto(7) do |file|
        piece = self[[file, rank]]
        output += "#{(piece.nil? ? ' ' : piece.to_s)} "
      end
      output += "\n"
    end
    output
  end

  def dup
    board_dup = self.class.new
    board_dup.pieces = pieces.map { |piece| piece.dup(board_dup) }
    board_dup.rehash
    board_dup
  end

  def on_board?(pos)
    pos.all? { |coord| coord.between?(0,7) }
  end

  def my_pieces(color)
    @pieces.select { |piece| piece.color == color }
  end

  def rehash
    @positions_hash = @pieces.reduce({}) do |hash, piece|
      hash[piece.pos] = piece
      hash
    end
  end

  def lost?(color)
    my_pieces(color).map { |piece| piece.moves.count }.reduce(0, :+) == 0
  end

  def self.parse_string(string)
    digit_part = /[^[:digit:]]*([[:digit:]]*)/.match(string)[1]
    alpha_part = /[^[:alpha:]]*([[:alpha:]])/.match(string)[1]
    
    if digit_part.empty? || alpha_part.empty?
      fail 'Coordinates should be a letter/number pair, e.g. "b2"'
    end
    
    x = alpha_part.downcase.ord - 'a'.ord
    y = digit_part.to_i - 1

    [x, y]
  end

end