


class @Position
  constructor: (@turn) ->
    @w = 20; @h = 20
    @last_move = null
    @sq = new Array(@w)
    for i in [0...@w]
      @sq[i] = new Array(@h)
      for j in [0...@h]
        @sq[i][j] = "_"

    if @turn == "O" then @move2(9,8)
    @winner_row = []


  move2: (x,y) ->
    @sq[x][y] = @turn
    @last_move = [x,y]
    @check_five(x,y)
    @turn = if @turn == "X" then "O" else "X"

    x_low = if (x-2) > 0 then x-2 else 0
    x_up = if (x+2) < 20 then x+2 else 19
    y_low = if (y-2) > 0 then y-2 else 0
    y_up = if (y+2) < 20 then y+2 else 19

    for i in [x_low..x_up]
      for j in [y_low..y_up]
        if not (@sq[i][j] == "O" or @sq[i][j] == "X")
          @sq[i][j] = '-'

    return true

  print: () ->

    for i in @sq
      str = ""
      for j in i
        if parseInt(j) < 0
          str = str[...-1] # poista välilyönti
          str += j + " "
        else
          str += j + " "

      console.log str

Position::from_to = (x,y, step_x, step_y, len) ->
  str = ""
  for i in [0...len]
    if (x >= 0 && x < 20) and (y >= 0 && y < 20)
      str += @sq[x][y]
    x += step_x
    y += step_y

  return str

Position::row_value3 = (str,c) ->
  four = c+c+c+c
  three = c+c+c
  three2 = c+c+'-'+c
  str = str.replace(/_/g,'-')

  f = if c == "O" then 1 else 0

  if (i = str.search(c+c+c+c+c)) != -1
    return 100000 + f*10000
  if (i = str.search(c+c+c+c)) != -1
    if str[i-1] == "-" and str[i+4] == "-"
      return 10000 + f*10000
    if str[i-1] == "-" or str[i+4] == "-"
      return 900 + f*500
    return 0
  if (i = str.search(c+c+c+"-"+c + "|" + c+"-"+c+c+c)) != -1
    return 800 + f*500

  if (i = str.search(c+c+c)) != -1
    if str[i-2...i] == "--" and str[i+3...i+5] == "--"
      return 1000 + f*1000
    if str[i-2...i] == "--" or str[i+3...i+5] == "--"
      return 300 + f*100
    return 0
  if (i = str.search(c+c+'-'+c)) != -1 or (i = str.search(c+'-'+c+c)) != -1
    if str[i-2...i] == "--" and str[i+4...i+6] == "--"
      return 800 + f*100
    if str[i-2...i] == "--" or str[i+4...i+6] == "--"
      return 500 + f*100
    return 0
  if (i = str.search('--'+c+c+'--')) != -1
    return 100 + f*100

  return 0

Position::square_value = (x,y) ->
  #left = if x - 5 < 0 then 0 else x - 5
  #top = if y - 5 < 0 then 0 else y - 5
  #right = if x + 5 >= 20 then 19 else x + 5
  total = 0
  for c in ["X","O"]
    @sq[x][y] = c
    str = @from_to(x, y-5, 0, +1, 11) #vertical
    total += @row_value3(str, c)
    str = @from_to(x-5, y, +1, 0, 11) #horizontal
    total += @row_value3(str, c)
    str = @from_to(x-5, y-5, +1, +1, 11) #diagonal
    total += @row_value3(str, c)
    str = @from_to(x+5, y-5, -1, +1, 11) #diagonal
    total += @row_value3(str, c)

  #console.log total
  @sq[x][y] = "-" # undo move
  return total

Position::check_five = (x,y) ->

  c = @turn

  xs = x - 5
  if xs < 0 then xs = 0
  ys = y - 5
  if ys < 0 then ys = 0

  str = @from_to(x, y-5, 0, +1, 11) #vertical
  if (i = str.search(c+c+c+c+c)) != -1
    @winner_row = [x,ys+i,x,ys+i+4]

  str = @from_to(x-5, y, +1, 0, 11) #horizontal
  if (i = str.search(c+c+c+c+c)) != -1
    @winner_row = [xs+i,y,xs+i+4,y]

  if (x-5)<=0 or (y-5)<=0
    xs = if x>y then x-y else 0
    ys = if y>x then y-x else 0
    #console.log "xs: " + xs + "ys: " + ys

  str = @from_to(x-5, y-5, +1, +1, 11) #diagonal
  if (i = str.search(c+c+c+c+c)) != -1
    @winner_row = [xs+i,ys+i,xs+i+4,ys+i+4]


  xs = x + 5
  ys = if y-5 < 0 then 0 else y-5

  if (x+5) >= 19 or (y-5) <= 0
    xs = if (19-x)>y then x+y else 19
    ys = if y>(19-x) then y-(19-x) else 0
    #console.log "xs: " + xs + "ys: " + ys

  str = @from_to(x+5, y-5, -1, +1, 11) #diagonal
  if (i = str.search(c+c+c+c+c)) != -1
    @winner_row = [xs-i,ys+i,xs-i-4,ys+i+4]

  return false


Position::make_move = () ->
  console.log @negamax(0, this) + " ============"
  moves = []
  for i in [0...@w]
    for j in [0...@h]
      if @sq[i][j] == '-'
        moves.push({value: @square_value(i,j), move: [i,j]})

  # sort bests (max values) to be first
  moves.sort((a,b) -> b.value - a.value)
  #console.log max + " " + best_move
  console.log moves
  @move2(moves[0].move[0],moves[0].move[1])
  
  
Position::position_value = () ->
  moves = []
  for i in [0...@w]
    for j in [0...@h]
      if @sq[i][j] == '-'
        moves.push({value: @square_value(i,j), move: [i,j]})

  # sort bests (max values) to be first
  moves.sort((a,b) -> b.value - a.value)
  #console.log max + " " + best_move
  return moves[0].value

Position::negamaxW = (depth) ->

  f = if @turn == "O" then 1 else -1

  if depth == 0 or @check_five(@last_move[0],@last_move[1])
    return f * @position_value()

  newPos = clone(this) # $.extend(true, {}, this)
  bestVal = -10000000
  for i in [0...@w]
    for j in [0...@h]
      if @sq[i][j] == '-'
        newPos.move2(i,j)
        val = -newPos.negamax(depth-1)
        bestVal = Math.max(val, bestVal)
        #console.log val

  return bestVal


Position::negamax = (depth, pos) ->

  f = if @turn == "O" then 1 else -1

  if depth == 0 or @check_five(@last_move[0],@last_move[1])
    return f * @position_value()

  bestVal = -10000000
  for i in [0...@w]
    for j in [0...@h]
      if @sq[i][j] == '-'
        newPos = clone(this)
        newPos.move2(i,j)
        val = -newPos.negamax(depth-1, newPos)
        bestVal = Math.max(val, bestVal)
        #console.log val

  return bestVal



arrayEqual = (a, b) ->
  a.length is b.length and a.every (elem, i) -> elem is b[i]


clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date(obj.getTime()) 

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global?
    flags += 'i' if obj.ignoreCase?
    flags += 'm' if obj.multiline?
    flags += 'y' if obj.sticky?
    return new RegExp(obj.source, flags) 

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance
