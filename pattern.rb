load("distance.rb")
load("make2d.rb")
include(Math)

def pattern(s)
  image = make2d(s,s)
  scale = s/100.0
  size = s*1.0
  # background gradient with some random stars
  for y in 0..(s-1)
    for x in 0..(s-1)
    	dither = (rand(10)-5)/150.0 #to account for the small palette, add some randomness to the hue in the gradient
    	glow = [0, (x/size)-0.5 + dither].max	#some glow from the below
    	r = glow * 0.5
    	b = glow + [0, 0.5-(x/size)].max #add some blue to the top  
    	g = glow
    	image[x][y] = [r,g,b]
    	if rand(size) < 1	#add a somewhat constant number of stars to the sky
    		brightnes = rand(10)/15.0 + 0.2
    		image[x][y] = [brightnes,brightnes,brightnes]
    	end
    end
  end
  
  
  # the moon
  for x in (20*scale).to_i..(40*scale).to_i	#only loop through the rough bounding box
    for y in (60*scale).to_i..(80*scale).to_i
      if distance(x,y,30*scale,70*scale)<7*scale	#moon is at 35%x,70%y and is 7% radius. The second condition is the shadow of the moon, which is another similiar circle, slightly offset, that cancels out the first.
        image[x][y] = [0.9,0.9,1.0]	#slightly bluish white for the colour of the moon
        if distance(x,y,29*scale,74*scale)<7*scale
        	image[x][y] = [0,0,0] #but if insite the shadow, make colour black
        end
      end
    end
  end
  
  #tower
  for x in 0..(s-1)#(30*scale).to_i..(60*scale).to_i	#only loop through the rough bounding box
    for y in 0..(s-1)#(40*scale).to_i..(s-1)
    	if (x-scale*30) >= (s/2-y).abs*10 || (x-scale*60) > (s/2-y).abs*2 	#if inside any of two sharp triangles in the middle of the picture
    		shade = [0, (x/size)-0.2].max	#some shade from the below
    		if x % (scale*14) > scale*6 #make colour white at regular intervals, otherwise red
    			stripe = 1
    		else
    			stripe = 0
    		end
    		r = shade
    		g = shade *stripe
    		b = shade *stripe
    		image[x][y] = [r,g,b]
    	end
    end
  end
  
  if s > 10 #small scale causes problems
  #tall buildings
  y = 0
  maxwidth = 15*scale #max width of one building
  maxheight = 30*scale
  while y<s-1
  	width = rand(maxwidth) + (scale*3).to_i	#add some extra to avoid super thin or short buildings
  	height = rand(maxheight) + (scale*10).to_i
  	if rand(5) < 3 #if this building is to have windows
  		windows = 1#rand(5)/5.0 #different brightneses
  	else
  		windows = 0
  	end
  	for yy in y.to_i..[y+width,s-1].min #only go to the edge
  		if rand(2)==0
  			windows2 = 0
  		else
  			windows2 = 1
  		end
  		for xx in s-height..s-1
  			image[xx][yy] = [xx%2*windows*windows2*0.5 + 0.1,xx%2*windows*windows2*0.8 + 0.15,xx%2*windows*windows2*0.7 + 0.15]	#add the window colour to even rows. Some buildings have black windows
  		end
  	end
  	y += width
  end
  
  #small buildings
  y = 0
  maxwidth = 10*scale #max width of one building
  maxheight = 20*scale
  while y<s-1
  	width = rand(maxwidth) + (scale*3).to_i	#add some extra to avoid super thin or short buildings
  	height = rand(maxheight) + (scale*3).to_i
  	for yy in y.to_i..[y+width,s-1].min #only go to the edge
  		for xx in (s-height)..(s-1)
  			image[xx][yy] = [0,0,0]
  		end
  	end
  	y += width
  end
  end

  image
end

def kadai02time ()
	300
end