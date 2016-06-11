#get bmi
def bmi(height, weight)
  weight / (height/100.0) ** 2 # ** is the same as ^ in other languages
end
