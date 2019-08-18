


class Position
  constructor: (@w, @h) ->

    @sq = new Array(@w)
    for i in [0...@w]
      @sq[i] = new Array(@h)
      for j in [0...@h]
        @sq[i][j] = "_"

    #@sq[0][19] = "J"
    @turn = "X"

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

  move2: (x,y,c) ->
    @sq[x][y] = c
    @turn = if @turn == "X" then "O" else "X"

    for i in [(x-2)..(x+2)]
      for j in [(y-2)..(y+2)]
        if not (@sq[i][j] == "O" or @sq[i][j] == "X")
          @sq[i][j] = '*'

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

Position::from_to = (x,y,step_x, step_y, len) ->
  str = ""
  for i in [0...len]
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
  three2 = c+c+'e'+c
  if (i = str.search(c+c+c+c)) != -1
    if str[i-1] == "e" and str[i+4] == "e"
      return 1000
    if str[i-1] == "e" or str[i+4] == "e"
      return 100
    return 0
  if (i = str.search(c+c+c)) != -1
    if str[i-2...i] == "ee" and str[i+3...i+5] == "ee"
      return 1000
    if str[i-2...i] == "ee" or str[i+3...i+5] == "ee"
      return 500
    return 0
  if (i = str.search(c+c+'e'+c)) != -1 or (i = str.search(c+'e'+c+c)) != -1
    if str[i-1] == "e" and str[i+4] == "e"
      return 900
    if str[i-1] == "e" or str[i+4] == "e"
      return 100
    return 0
  if (i = str.search('ee'+c+c+'ee')) != -1
    return 10

  return 0

arrayEqual = (a, b) ->
  a.length is b.length and a.every (elem, i) -> elem is b[i]


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
console.log b.from_to(0,0,+1,+1, 10)
console.log b.from_to(0,19,+1,-1,15)
console.log b.from_to(10,10,+1,-1,10)
console.log b.from_all([10,10],[+1,-1])
console.log b.from_all([0,0],[+1,+1])
###
console.log b.value()
b.print()

if (i = "eXXee".search("XXeX")) != -1
  console.log i

c = "X"
console.log c+c+c+c
