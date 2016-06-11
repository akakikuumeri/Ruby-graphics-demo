#!/usr/bin/env ruby
# check data for Week #2, Information Science, 2011, Masuhara's class
# Wed Oct 12 19:28:23 JST 2011

$testunits__ = 
  [["distance.rb",
    [["Ex1.3",   "distance",              "float", 5.0,      0, 0, 3, 4]]],
   ["yardpound.rb",
    [["Ex1.3",   "feet_to_cm",            "float", 896.62,  29, 5],
     ["Ex1.3",   "pound_to_kg",           "float", 0.07370,  0.1, 1],
    ]],
   ["quadratic.rb",
    [["Ex1.9 g-a", "det", "float", 9, 1.0, 1.0, -2.0],
     ["Ex1.9 g-b", "solution1", "float", 1, 1.0, 1.0, -2.0],
    ]],
   ["bmi_yp.rb",
    [["Ex1.10", "bmi_yp", "float", 23.7103429969605, 5, 11, 170, 0]]],
   ["abs.rb",
    [["Ex3.1", "abs", "int", 123, -123],
     ["Ex3.1", "abs", "int", 123,  123]]],
   ["sphere.rb",
    [
     ["Ex3.2", "b", "float", 1.0,     100,50,50],
     ["Ex3.2", "b", "float", 0.8,     100,40,50],
     ["Ex3.2", "b", "float", 1.0,     100,50,50],
     ["Ex3.2", "b", "float", 0.0,     100, 0,50],
     ["Ex3.2", "b", "float", 1,       100, 5, 5],
     ["Ex3.2", "b", "float", 0.01005, 100,15,15],
     ["Ex3.2", "b", "float", 1,       100,95,95],
     ["Ex3.2", "b", "float", 0.01005, 100,85,85],
    ]],
   ["median.rb",
    [["Ex3.3 c", "median", "float", 1, 0, 1, 2],
     ["Ex3.3 c", "median", "float", 1, 0, 2, 1],
     ["Ex3.3 c", "median", "float", 1, 1, 0, 2],
     ["Ex3.3 c", "median", "float", 1, 1, 2, 0],
     ["Ex3.3 c", "median", "float", 1, 2, 1, 0],
     ["Ex3.3 c", "median", "float", 1, 2, 0, 1],
    ]],
   ["pattern.rb",
    [
     ["kadai2-2", "pattern", "image", Array.new(5  ){Array.new(5,  0)}, 5  ],
     ["kadai2-2", "pattern", "image", Array.new(10 ){Array.new(10, 0)}, 10 ],
     ["kadai2-2", "pattern", "image", Array.new(100){Array.new(100,0)}, 100],
     ["kadai2time", "kadai02time", "positive", "any positive number"],
    ]],

  ]


def equal_image(expected, actual) # check if the actual is a 2 or 3 dimensional
  width=expected[0].length()      # array of the same size as expected.  
  
  (actual.kind_of?(Array) &&
   actual.length == expected.length &&
   actual.all? { |row|
     row.kind_of?(Array) && row.length == width
   } &&
   (actual.all? { |row|
      row.all? { |pixel|
        (pixel.kind_of?(Array) && pixel.length == 3 &&
         pixel.all?{ |b| b.kind_of?(Numeric) })
       }
    } ||
    actual.all? { |row|
      row.all? { |pixel| pixel.kind_of?(Numeric) }
    }))
end


def equal_positive(expected, actual)
  actual.kind_of?(Numeric) && actual>=0
end
