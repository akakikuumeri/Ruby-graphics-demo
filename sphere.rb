load("distance.rb")
load("make2d.rb")

def b(s,x,y)
  if distance(x,y,s/2.0,s/2.0) <= s/2.0
    (s/2-distance(x,y,s/2.0,s/2.0))/(s/2.0)
  else
    1
  end
end

def sphere(s)
  image = make2d(s,s)
  for y in 0..(s-1)
    for x in 0..(s-1)
      image[y][x] = b(s,x,y)
      end
    end
  image
end
