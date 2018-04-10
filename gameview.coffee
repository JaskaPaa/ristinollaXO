

class @GameView extends Backbone.View

  el: $ 'body'

  initialize: ->
    _.bindAll @
    @board = $('#board').get(0)
    @squareSize = @board.width / 20
    @render()
    #@model.bind "change", @render
    @listenTo(@model, "change", @render)

  render: ->
    $('#talk').text("Sinun vuorosi.")
    $('#talk').prop('disabled', true)
    @renderGrid('blue')
    @renderPosition()
    #@model.runEngine()
    @talk()
    $('#xscore').text(@model.wins.X)
    $('#oscore').text(@model.wins.O)
    return @

  talk: ->
    pos = @model.get('position')
    console.log pos
    
    if pos.last_move == null
      $('#talk').text("Sinun vuorosi aloittaa...")
    if @model.get('winner') == "O"
      $('#talk').text("Minä voitin!!!Minä voitin!!!")
    if @model.get('winner') == "X"
      $('#talk').text("Okei, voitit...")

  renderPosition: ->
    pos = @model.get('position')
    for i in [0...pos.w]
      for j in [0...pos.h]
        if pos.sq[i][j] == "O" then @renderO(i,j)
        if pos.sq[i][j] == "X" then @renderX(i,j)

    #@showLastMove(4)
    #console.log pos.last_move

    if @model.get('winner') in "OX"
      #console.log @model.get('winner')
      #console.log pos.winner_row
      @drawWinnerLine(pos.winner_row)

      $('#new').prop('disabled', false)
    else
      $('#new').prop('disabled', true)

    return @

  showLastMove: (count = 6) ->

    if count == 0 then return

    pos = @model.get('position')
    if pos.last_move == null then return

    x = pos.last_move[0]
    y = pos.last_move[1]

    if count%2 == 0
      @clearSquare(x,y)
    else
      if pos.sq[x][y] == "O" then @renderO(x,y)
      if pos.sq[x][y] == "X" then @renderX(x,y)

    @drawWinnerLine pos.winner_row     # if any
    setTimeout (=> @showLastMove(count-1)), 200

    return null

  drawWinnerLine: (arr) ->
    #console.log "drawing line..."
    return if (not arr?) or arr.length !=4

    context = @board.getContext('2d')
    context.beginPath()
    context.lineWidth = 5
    s = @squareSize
    context.moveTo arr[0]*s + s/2, arr[1]*s + s/2
    context.lineTo arr[2]*s + s/2, arr[3]*s + s/2
    context.closePath()
    context.stroke()
    return

  renderX: (x,y) ->
    x = x * @squareSize + @squareSize/2
    y = y * @squareSize + @squareSize/2
    z = Math.floor @squareSize/3
    context = @board.getContext('2d')
    context.beginPath()
    context.lineWidth = 2
    context.moveTo x - z, y - z
    context.lineTo x + z, y + z
    context.moveTo x - z, y + z
    context.lineTo x + z, y - z
    context.closePath()
    context.stroke()
    return

  renderO: (x,y) ->
    context = @board.getContext('2d')
    #context.clearRect(0, 0, @board.width, @board.height)
    #@renderGrid "blue"
    x = x * @squareSize + @squareSize/2
    y = y * @squareSize + @squareSize/2
    z = Math.floor @squareSize/3
    context.beginPath()
    context.arc(x, y, z, 0, 2 * Math.PI, false)
    context.lineWidth = 1.9
    #context.strokeStyle = '#003300'
    context.stroke()
    context.closePath()

  canvasClick: (e) =>
    x = Math.floor((e.pageX-$("#board").offset().left) / @squareSize)
    y = Math.floor((e.pageY-$("#board").offset().top) / @squareSize)
    if @model.get('position').turn == "O" then return
    @model.move(x,y,"X")
    #@undelegateEvents()
    #@delegateEvents()
    #console.log "klick"

  newClick: (e) ->
    @model.initialize()
    $('#new').prop('disabled', true)

  lastClick: (e) ->
    @showLastMove(6)


  events:
    'click #board': 'canvasClick'
    'click #new': 'newClick'
    'click #last': 'lastClick'

GameView::clearSquare = (x,y) ->
  context = @board.getContext('2d')
  context.save()

  x = x * @squareSize + 2
  y = y * @squareSize + 2
  context.clearRect(x, y, @squareSize-4, @squareSize-4)
  context.restore()

GameView::renderGrid = (color) ->
  context = @board.getContext('2d')
  context.save()
  context.lineWidth = 0.5
  context.strokeStyle = color
  context.clearRect(0, 0, @board.width, @board.height)
  # horizontal grid lines
  i = 0
  while i <= @board.height
    context.beginPath()
    context.moveTo 0, i
    context.lineTo @board.width, i
    context.closePath()
    context.stroke()
    i = i + @squareSize
  # vertical grid lines
  j = 0
  while j <= @board.width
    context.beginPath()
    context.moveTo j, 0
    context.lineTo j, @board.height
    context.closePath()
    context.stroke()
    j = j + @squareSize
  context.restore()
  return
