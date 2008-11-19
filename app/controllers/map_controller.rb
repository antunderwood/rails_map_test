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
    regions = Region.find_by_sql ["SELECT country_code, nuts_id, simplify(the_geom,0.1) as the_geom  FROM regions where country_code = ? AND stat_level = ?" , params[:country], 0] # this sql could potentially return several regions therefore it is an array of Region objects
    @polygons = Array.new
    regions.each do |region| 
      @polygons += get_polygons(region.the_geom.geometries)
    end
  end
  def show_sequence_type
    # region = Region.find_by_country_code_and_stat_level(params[:country], 0)
    region_results = Strain.find_by_sql ["SELECT country, region, source FROM strains where sequence_type = ?" , params[:sequence_type]] # this sql could potentially return several regions therefore it is an array of Region objects
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
            @region_counts[country][region]["coordinates"] = get_polygons(coords.the_geom.geometries)
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
end
