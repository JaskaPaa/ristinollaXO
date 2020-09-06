

sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms


class @Game extends Backbone.Model
  next_starter: "X"
  wins: {X: 0, O: 0}
  initialize: ->
    @set {position: new Position(@next_starter)}
    @next_starter = if @next_starter == "X" then "O" else "X"
    @set {update: true}
    @thinking = false
    @set {winner: false }
    @set {update: !@get('update')}



  move: (x,y,c) ->
    pos = @get('position')
    #check illegal moves
    if c != pos.turn then return
    if pos.sq[x][y] in "OX" then return
    if @thinking then return
    if @get('winner') != false then return

    pos.move2(x,y)
    @set {position: pos}
    if pos.winner_row.length > 0
      @set {winner: c }
      @wins.X++
      @set {update: !@get('update')}
      return

    if pos.turn == "O"
      @thinking = true
      pos.make_move()
      @set {position: pos}
      @thinking = false
      if pos.winner_row.length > 0
        @set {winner: "O" }
        @wins.O++
      @set {update: !@get('update')}



new GameView({model: new Game})

Backbone.sync = (method, model, success, error) ->
  success()
