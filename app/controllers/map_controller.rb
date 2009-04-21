class MapController < ApplicationController

  def index
    @sequence_types = Strain.find( :all, :select => 'DISTINCT sequence_type', :order => :sequence_type ).map{|strain| strain.sequence_type.to_i}
  end
  def info
    respond_to do |format|
      format.html {
        if request.xhr?
          render :layout => false
        end
      }
      format.xml  { render :xml }
    end
  end 
  def show_location_info
    respond_to do |format|
      format.html {
        if request.xhr?
          render :layout => false
        end
      }
      format.xml  { render :xml }
    end
  end
  def add_markers
    @coord_array = [[-33.941, 18.489], [-34.045, 18.630], [-34.091, 18.451], [-34.002, 18.391], [-33.941, 18.489]]
  end
  def show_country
    # region = Region.find_by_country_code_and_stat_level(params[:country], 0)
    regions = Region.find_by_sql ["SELECT country_code, nuts_id, simplify(the_geom,0.01) as the_geom  FROM regions where country_code = ? AND stat_level = ?" , params[:country], 3] # this sql could potentially return several regions therefore it is an array of Region objects
    @polygons = Array.new
    regions.each do |region|
      if params[:not_encoded]
        @polygons += get_polygons(region.the_geom.geometries)
        @encoded = false
      else
        @polygons += get_encoded_polygons(region.the_geom.geometries)
        @encoded = true
      end 
      
    end
  end
  def show_sequence_type
    # region = Region.find_by_country_code_and_stat_level(params[:country], 0)
    region_results = Strain.find_by_sql ["SELECT country, region, source FROM strains where sequence_type = ?" , params[:sequence_type]] # this sql could potentially return several regions therefore it is an array of Region objects
    @number_of_regions = region_results.size
    @region_counts = Hash.new
    region_results.each do |region_result|
      country = region_result.country
      region = region_result.region
      source = region_result.source
      if @region_counts.has_key?(country)
         if @region_counts[country].has_key?(region)
           if @region_counts[country][region].has_key?(source)
             @region_counts[country][region][source] = @region_counts[country][region][source]+1
           else
             @region_counts[country][region][source] = 1
           end
         else
           @region_counts[country][region] = Hash.new
           @region_counts[country][region][source] = 1
         end
      else
        @region_counts[country] = Hash.new
        @region_counts[country][region] = Hash.new
        @region_counts[country][region][source] = 1
      end
    end
    @region_counts.each_key do |country|
      @region_counts[country].each_key do |region|
        region_mapping = RegionMapping.find(:first, :conditions => ["name_asci like ?", "#{region}%"])
        unless region_mapping.nil?
          coords_array = Region.find_by_sql ["SELECT simplify(the_geom,0.05) as the_geom  FROM regions where nuts_id = ?" , region_mapping.nuts_id]
          coords_array.each do |coords|
            if params[:not_encoded]
              @region_counts[country][region]["coordinates"] = get_polygons(coords.the_geom.geometries)
              @region_counts[country][region]["encoded"] = false
            else
              @region_counts[country][region]["coordinates"] = get_encoded_polygons(coords.the_geom.geometries)
              @region_counts[country][region]["encoded"] = true
            end
          end
        end
      end
    end
  end
  
  def get_polygons(geometries)
    polygons = Array.new
    geometries.each do |multi_polygon|
      multi_polygon.rings.each do |ring|
        polygons << ring.points.map{|point| [point.y,point.x]}
      end
    end
    return polygons
  end
  def get_encoded_polygons(geometries)
    require 'encoder'
    polygons = Array.new
    geometries.each do |multi_polygon|
      multi_polygon.rings.each do |ring|
        encoder = GMapPolylineEncoder.new()
        point_data = ring.points.map{|point| [point.y,point.x]}
        polygons << encoder.encode(point_data)
      end
    end
    return polygons
  end
  def add_country_overlay
    require 'svg_processing'
    regions = Region.find_by_sql ["SELECT assvg(the_geom) as svg_string, box2d(the_geom) FROM regions where country_code = ? AND stat_level = ?" , params[:country], 2]
    @region_images = []
    regions.each_with_index do |region, region_number|
      create_country_image(region.svg_string, 'purple', "#{params[:country]}_#{region_number}.png")
      boundary_string = region.box2d
      boundary_string.sub!(/^BOX\(/,"")
      boundary_string.sub!(/\)$/,"")
      sw,ne = boundary_string.split(",")
      @region_images[region_number] = Hash.new
      @region_images[region_number]['image_name'] = "#{params[:country]}_#{region_number}.png"
      @region_images[region_number]['sw'] = sw
      @region_images[region_number]['ne'] = ne
    end
  end
end
