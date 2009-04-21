def create_country_image(svg_string, colour, image_name)
  require 'RMagick'
  # split into individual items including the M and Z characters
  svg_items = svg_string.split(" ")
  min_x = nil
  max_x = nil
  min_y = nil
  max_y = nil
  i = 0
  # find minium and maximum x and y values
  while i < svg_items.size
    if svg_items[i] =~ /(M|Z)/ # ignore the M and Z start and end characters
      i += 1
      next
    end
    x = svg_items[i].to_f
    y = svg_items[i+1].to_f
    min_x = x if min_x.nil? || x < min_x
    min_y = y if min_y.nil? || y < min_y
    max_x = x if max_x.nil? || x > max_x
    max_y = y if max_y.nil? || y > max_y
    i +=2
  end
  # calculate height and width
  x_width = max_x - min_x
  y_height = max_y - min_y
  # calculate the x and y scale values so that the width and height would be 400 pixels
  x_scale_factor = 200/x_width
  y_scale_factor = 200/y_height
  # find the minimum of these 2 so that the image will be no bigger than 400 pixels in each dimension
  scale_factor = [x_scale_factor, y_scale_factor].min
  # print out these vakues
  puts "min_x: #{min_x}  max_x: #{max_x} x_width: #{x_width }\nmin_y: #{min_y} max_y: #{max_y} y_height: #{y_height}"
  # transform so that all values > 0 and multiply by scale factor
  i = 0
  while i < svg_items.size
    if svg_items[i] =~ /(M|Z)/
      i += 1
      next
    end
    svg_items[i] = (svg_items[i].to_f - min_x)*scale_factor
    svg_items[i+1] = (svg_items[i+1].to_f - min_y)*scale_factor
    i +=2
  end
  # recreate svg string
  svg_string  = svg_items.join(" ")


  canvas = Magick::Image.new((x_width*scale_factor)+1,(y_height*scale_factor)+1){self.background_color = 'none'}
  gc = Magick::Draw.new

  gc.fill(colour)
  gc.fill_opacity(0.5)
  gc.stroke('black')
  gc.stroke_width(1)
  gc.path(svg_string)
  gc.draw(canvas)

  canvas.write("/var/www/rails/rails_map_test/public/images/#{image_name}")
end
  