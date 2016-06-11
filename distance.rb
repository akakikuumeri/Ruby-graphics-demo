#distance between two 2d points
include(Math)
def distance(x,y,u,v)
  sqrt((x - u) ** 2 + (y - v) ** 2)
end
