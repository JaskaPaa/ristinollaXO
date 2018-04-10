$('#myCanvas').click (e) ->
  #alert(e.clientX +" "+ e.clientY +" "+ e.offsetX);
  e = e or window.event
  console.log this
  target = e.target or e.srcElement
  rect = target.getBoundingClientRect()
  offsetX = e.clientX - (rect.left)
  offsetY = e.clientY - (rect.top)
  #$scope.b.move2(2,2,'X');
  console.log [
    Math.floor(offsetX / 30)
    Math.floor(offsetY / 30)
  ]
  #$scope.b.move2(Math.floor(offsetX/30),Math.floor(offsetY/30),'X');
  #$scope.b.print();
  context = @getContext('2d')
  x = Math.floor(offsetX / 30) * 30 + 15
  y = Math.floor(offsetY / 30) * 30 + 15

  ###context.beginPath();
  context.arc(x, y, 12, 0, 2 * Math.PI, false);
  context.lineWidth = 2;
  //context.strokeStyle = '#003300';
  context.stroke();
  context.closePath();
  ###

  context.beginPath()
  context.lineWidth = 2
  context.moveTo x - 10, y - 10
  context.lineTo x + 10, y + 10
  context.moveTo x - 10, y + 10
  context.lineTo x + 10, y - 10
  context.closePath()
  context.stroke()
  return

$(document).ready ->
  canvas = $('#myCanvas').get(0)
  context = canvas.getContext('2d')

  renderGrid = (gridPixelSize, color) ->
    context.save()
    context.lineWidth = 0.5
    context.strokeStyle = color
    # horizontal grid lines
    i = 0
    while i <= canvas.height
      context.beginPath()
      context.moveTo 0, i
      context.lineTo canvas.width, i
      context.closePath()
      context.stroke()
      i = i + gridPixelSize
    # vertical grid lines
    j = 0
    while j <= canvas.width
      context.beginPath()
      context.moveTo j, 0
      context.lineTo j, canvas.height
      context.closePath()
      context.stroke()
      j = j + gridPixelSize
    context.restore()
    return

  renderGrid canvas.width / 20, 'blue'
  return
