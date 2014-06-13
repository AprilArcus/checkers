w2d4

Questions from last time:

Why did you make slideable and stepable modules instead of subclasses?
----------------------------------------------------------------------

'we normally make things classes when they have some state that they have to
manage - when there's an initialize method that should be called at the
beginning of class construction. Modules are when we want to add methods that
are defined in terms of other methods in the class'

modules are typically used in ruby to say 'you have some methods? I will plug
some extra power into you.' modules are more flexible in that you can only
inherit from a single base class, but you can mix in as many modules as you
like. Modules expect there to be a set of methods they can use, but they don't
care how those methods are implemented.

Advice about exceptions
-----------------------

Abstractions leak when exceptions are thrown

case of pawn promotion - maybe pass in a 'promotion_proc' on init to handle
getting input? Ned called this a 'callback style'

Checkers
--------

Classes: Board, Piece

Piece has an ivar @king

do not immediately implement chained jumping moves
methods for legal sliding moves and single jumps

Piece:
	sliding moves / perform slide
	jumping moves / perform jump
	perform moves!(array of pos)
		* slide
		* jumps <- repeatedly call perform jump
	perform moves
		* dups board
		* perform moves!
		* If no error play on real board