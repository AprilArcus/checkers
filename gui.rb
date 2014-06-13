#! /usr/bin/env ruby

require 'gosu'
require_relative 'checkers'

class NilPieceError < RuntimeError
end

class WrongPieceError < RuntimeError
end

class GameError < RuntimeError
end

class GUICheckers < Gosu::Window

  def initialize
    super(640, 640, false)
    @board = Board.setup
    @current_player = :black
    @count = 0
    @background =   Gosu::Image.new(self, './assets/background.png',   false)
    @white_piece =   Gosu::Image.new(self, './assets/white_piece.png',   false)
    @white_king =   Gosu::Image.new(self, './assets/white_king.png',   false)
    @black_piece =   Gosu::Image.new(self, './assets/black_piece.png',   false)
    @black_king =   Gosu::Image.new(self, './assets/black_king.png',   false)
    @moves = []
  end

  def change_players
    @count += 1
    @current_player = ((@current_player == :black) ? :white : :black)
  end

  def coords_to_pixels(pos)
    x, y = pos
    [x * 80, 640-((y+1) * 80)]
  end
  
  def pixels_to_coords(pixel)
    x, y = pixel
    [(x/80).to_i, ((640-y)/80).to_i]
  end

  def get_coords
    pixels_to_coords([mouse_x, mouse_y])
  end

  def draw
    @background.draw(0, 0, 0)
    @board.pieces.each do |piece|
      x, y = coords_to_pixels(piece.pos)
      @white_piece.draw(x, y, 1) if piece.color == :white && !piece.king
      @white_king.draw(x, y, 1) if piece.color == :white && piece.king
      @black_piece.draw(x, y, 1) if piece.color == :black && !piece.king
      @black_king.draw(x, y, 1) if piece.color == :black && piece.king
    end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    @moves << get_coords
    p @moves
    if @moves.count >= 2
      begin
        piece = @board[@moves.first]
        raise GameError.new() if piece.nil? || piece.color != @current_player
        moves = @moves.drop(1)
        piece.perform_moves(moves) # MultiJumpError could be thrown here
        change_players
        @moves = []
      rescue GameError, InvalidMoveError => error
        puts error.message
        @moves = []
      rescue MultiJumpError => error
        puts error.message
      end
    end
  end


end

if __FILE__ == $PROGRAM_NAME
  GUICheckers.new.show
end