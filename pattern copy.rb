load("distance.rb")
load("make2d.rb")
include(Math)

def b1(s,x,y)
  if true #distance(x,y,s/2.0,s/2.0) <= s/2.0
   #if inside circle
    [x*1.00/s*1.00,  (1.0-y)*1.00/s*1.00,(x+y)/(s*2.0)]
  else
    [0.5,0.5,0.5]
  end
end


def b(s,x,y)
  if (x-(s/2.0)) == 0 #if right in the middle
    dir = PI/2.0
  else
    dir = atan((y-(s/2.0)) / (x-(s/2.0)))
  end
  value = dir/(PI) +0.5
  if x > s/2.0
    ret=value / 2.0 + 0.5
  else
    ret=value /2.0
  end
 [ret,ret,1.0]
end


def pattern(s)
  @image = make2d(s,s)
  scale = s/100
  #make background
  for y in 0..(s-1)
    for x in 0..(s-1)
      @image[y][x] = b(s,x,y)
    end
  end
  
  for x in 20*scale..50*scale
    for y in 40*scale..70*scale
      if distance(x,y,35*scale,55*scale)<15*scale
        @image[x][y] = [1,0,0]
      end
    end
  end

  loop(20,20,70,70,scale) { 
    if distance(@x,@y,50*scale,50*scale) < 20*scale
      @image[@x][@y] = [0,1,0]
    end }
  for x in 0..(s-1)
    for y in 0..(s-1)
      if rand(1) == 0
        @image[x][y] = 1-rand(50)/100.0
      end
    end
  end
  @image
end

def loop(x1,y1,x2,y2,scale)
  for @x in x1*scale..x2*scale
    for @y in y1*scale..y2*scale
      yield
    end
  end
end
