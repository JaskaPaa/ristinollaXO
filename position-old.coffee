


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

  move: (x,y,c) ->
    @sq[x][y] = c
    if c == "X"
      value = 1
    else
      value = -1
    for i in [(x-2)..(x+2)]
      for j in [(y-2)..(y+2)]
        if not (@sq[i][j] == "O" or @sq[i][j] == "X")
          if @sq[i][j] == "_"
            @sq[i][j] = 0
          @sq[i][j] += value
    for i in [(x-1)..(x+1)]
      for j in [(y-1)..(y+1)]
        if not (@sq[i][j] == "O" or @sq[i][j] == "X")
          if @sq[i][j] == "_"
            @sq[i][j] = 0
          @sq[i][j] += value

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

Position::from_all = (pos,step) ->
  str = ""
  while @sq[pos[0]]? && @sq[pos[1]]?
    str += @sq[pos[0]][pos[1]]
    pos[0] += step[0]
    pos[1] += step[1]

  return str

Position::value = () ->
  total = 0
  for i in [0...@h]
    row = @from_all([0,i],[+1,0])
    console.log row
    total += @row_value(row,"O")
    total -= @row_value(row,"X")
    console.log total
  for i in [0...@w]
    row = @from_all([i,0],[0,+1])
    console.log row
    total += @row_value(row,"O")
    total -= @row_value(row,"X")
    console.log total
  # diagonaanit
  for i in [0...@h]
    row = @from_all([0,i],[+1,+1])
    console.log row
    total += @row_value(row,"O")
    total -= @row_value(row,"X")
    console.log total
  for i in [1...@w]
    row = @from_all([i,0],[+1,+1])
    console.log row
    total += @row_value(row,"O")
    total -= @row_value(row,"X")
    console.log total
  for i in [0...@W]
    row = @from_all([0,i],[+1,-1])
    console.log row
    total += @row_value(row,"O")
    total -= @row_value(row,"X")
    console.log total
  for i in [1...@w]
    row = @from_all([i,@w-1],[+1,-1])
    console.log row
    total += @row_value(row,"O")
    total -= @row_value(row,"X")
    console.log total

  return total

Position::row_value2 = (str) ->
  x_count = 0
  o_count = 0
  empty = [0,0,0] #etu, keski ja taka tyhjät
  value = 0
  last = ""
  for i in str
    if i in "_*" then empty[0] += 1
    if (i in "_*" && last == 'X') then empty[1] += 1
    if (i in "_*" && empty[1] > 0) then empty[2] += 1
    if i == "X" then x_count += 1
    if x_count > 0
      value += -o_count*10
      o_count = 0
    if i == "O" then o_count += 1
    if o_count > 0
      value += x_count*10
      x_count = 0

    last = i

  return empty
  #return value

Position::row_value = (str,c) ->
  x_count = 0
  empty = [0,0,0] #etu, keski ja taka tyhjät
  value = 0
  prev = ""
  opp = if c == "X" then "O" else "X"
  for i in str
    if (i in "*" && prev == c) then empty[1] += 1
    if (i in "*" && empty[1] > 0) then empty[2] += 1
    if i in "*" && empty[1] == 0 && empty[2] == 0 then empty[0] += 1
    if i == c then x_count += 1
    if i == opp or empty[2] > 1
      console.log empty
      if empty[0] > 2 then empty[0] = 2
      if empty[1] == 1 then empty[2] += 1
      if x_count >= 2
        value += Math.pow(5,x_count)
        value = (value/2) * empty[0] + (value/2) * empty[2]
        #if @turn == c then value *= 10
      x_count = 0
      empty = [0,0,0]

    prev = i

  #return empty
  return value

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


Position::make_move = () ->
  max = -1
  for i in [0...@w]
    for j in [0...@h]
      if @sq[i][j] == '-'
        tmp = @square_value(i,j)
        if tmp > max
          max = tmp
          best_move = [i,j]
          #console.log max + " ::: " + best_move
  #console.log max + " " + best_move
  @move2(best_move[0],best_move[1])


arrayEqual = (a, b) ->
  a.length is b.length and a.every (elem, i) -> elem is b[i]

###
b = new Position(20,20)
b.move2(9,7,"X")
b.move2(9,9,"O")
b.move2(10,10,"X")
b.move2(9,10,"O")
b.move2(11,9,"X")
b.move2(9,11,"O")
b.move2(9,12,"X")
b.move2(9,8,"O")
b.move2(10,11,"X")
b.move2(10,12,"O")
b.move2(12,9,"X")

b.print()
###

###
console.log b.from_to(0,0,+1,+1, 10)
console.log b.from_to(0,19,+1,-1,15)
console.log b.from_to(10,10,+1,-1,10)
console.log b.from_all([10,10],[+1,-1])
console.log b.from_all([0,0],[+1,+1])
###

###
console.log b.value()
b.print()

if (i = "eXXee".search("XXeX")) != -1
  console.log i

c = "X"
console.log c+c+c+c
###
