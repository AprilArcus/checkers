#! /usr/bin/env ruby

require_relative 'board'

class GameError < RuntimeError
end

class Checkers

  def initialize
    @board = Board.setup
    @count = 0
    @current_player = :black
  end

  attr_reader :board
  attr_accessor :count, :current_player

  def other_player
    (@current_player == :black) ? :white : :black
  end

  def get_moves
    gets.chomp.split(',').map(&:strip)
  end

  def play_turn
    moves = get_moves
    if moves.length < 2
      raise GameError.new("You must specify at least an origin and destination coordinate")
    end
    piece = @board[moves.shift]
    if piece.nil?
      raise GameError.new("There's no piece there.")
    end
    if piece.color != @current_player
      raise GameError.new("You may only move your own pieces.")
    end
    piece.perform_moves(moves)
  end

  def change_players
    @count += 1
    @current_player = ((@current_player == :black) ? :white : :black)
  end

  def play
    until @board.lost?(@current_player)
      p @board
      puts "Turn #{@count}, #{@current_player} to move."
      puts "Enter a comma-delimited list of moves."
      begin
        play_turn
      rescue GameError, InvalidMoveError, MultiJumpError => error
        puts error.message
        retry
      end
      change_players
    end
    puts "Game over! #{other_player} wins."
  end

end

if __FILE__ == $PROGRAM_NAME
  Checkers.new.play
end