# encoding: utf-8
class InvalidMoveError < RuntimeError
end

class InvalidStepError < RuntimeError
end

class MultiJumpError < RuntimeError
end

class Piece

  WHITE_STEPS = [[-1,  1], [1,  1]]
  BLACK_STEPS = [[-1, -1], [1, -1]]
  WHITE_JUMPS = [[-2,  2], [2,  2]]
  BLACK_JUMPS = [[-2, -2], [2, -2]]

  def initialize(board, pos, color, king = false)
    @board = board
    @pos = pos
    @color = color
    @king = king
  end

  attr_reader :pos, :color, :king

  def step_vectors
    return WHITE_STEPS if @color == :white &&!@king
    return BLACK_STEPS if @color == :black &&!@king
    WHITE_STEPS.concat(BLACK_STEPS)
  end

  def jump_vectors
    return WHITE_JUMPS if @color == :white &&!@king
    return BLACK_JUMPS if @color == :black &&!@king
    WHITE_JUMPS.concat(BLACK_JUMPS)
  end

  def add_vector(vector)
    [@pos[0] + vector[0], @pos[1] + vector[1]]
  end

  def average_vector(end_pos)
    [(@pos[0] + end_pos[0]) / 2, (@pos[1] + end_pos[1]) / 2]
  end

  def steps
    step_positions = step_vectors.map { |vector| add_vector(vector) }
    step_positions.select do |pos|
      (@board.on_board?(pos) && @board[pos].nil?)
    end
  end

  def jumps
    jump_positions = jump_vectors.map { |vector| add_vector(vector) }
    jump_positions.select do |end_pos|
      jumped_pos = average_vector(end_pos)
      (@board.on_board?(end_pos) && @board[end_pos].nil? &&
       !@board[jumped_pos].nil? && @board[jumped_pos].color != @color)
    end
  end

  def moves
    steps.concat(jumps)
  end

  def crownable?
    (@color == :white && @pos[1] == 7) || (@color == :black && @pos[1] == 0)
  end

  def perform_step(end_pos)
    end_pos = Board.parse_string(end_pos) if end_pos.is_a?(String)

    unless steps.include?(end_pos)
      raise InvalidStepError.new # caught in perform_moves!
    end
    unless @board.my_pieces(@color).map { |piece| piece.jumps.count }.reduce(0, :+) == 0
      raise InvalidMoveError.new('You may not perform a simple move when a jump is available.')
    end

    @pos = end_pos
    @king = true if crownable?
    @board.rehash
  end

  def perform_jump(end_pos)
    end_pos = Board.parse_string(end_pos) if end_pos.is_a?(String)
    raise InvalidMoveError.new('Illegal move.') unless jumps.include?(end_pos)

    jumped_pos = average_vector(end_pos)
    @pos = end_pos
    raise MultiJumpError.new unless jumps.empty? # before kinging!
    @king = true if crownable?
    @board.pieces.delete(@board[jumped_pos])
    @board.rehash
  end

  def perform_moves!(moves)
    if moves.one?
      begin
        perform_step(moves.first) # can raise an InvalidMoveError
      rescue InvalidStepError
        perform_jump(moves.first) # can raise an InvalidMoveError
      end
    else
      was_king = @king
      last_move_idx = moves.count - 1
      moves.each_with_index do |move, move_idx|
        # Wikipedia: "If a player's piece jumps into kings' row,
        # the current moves terminates"
        if was_king != @king
          raise InvalidMoveError.new("Your turn ends after your piece is kinged.")
        end
        begin
          perform_jump(move)
        rescue MultiJumpError => error
          raise error if move_idx == last_move_idx
        end
      end
    end
  end

  def validate_move_seq(moves)
    board_dup = @board.dup
    piece_dup = board_dup[self.pos]
    was_king = piece_dup.king
    piece_dup.perform_moves!(moves) # allow exceptions to percolate up
    # if !piece_dup.jumps.empty? && was_king == piece_dup.king
    #   raise MultiJumpError.new("You must make all available jumps.")
    # end
  end

  def perform_moves(moves)
    validate_move_seq(moves) # allow exceptions to percolate up
    perform_moves!(moves) 
  end

  def to_s
    return '♙' if @color == :white && !@king
    return '♔' if @color == :white && @king
    return '♟' if @color == :black && !@king
    return '♚' if @color == :black && @king
  end

  def dup(board)
    self.class.new(board, @pos.dup, @color, @king)
  end

end