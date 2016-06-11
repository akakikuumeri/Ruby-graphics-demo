include(Math)
def det(a,b,c)
  b**2 - 4.0*a*c
end

def solution1(a,b,c)
  (-b + sqrt(det(a,b,c)))/(2*a)
end
