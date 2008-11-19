module MapHelper
  
  def init_map
    run_map_script do
      map = Google::Map.new(:controls => [:small_map, :map_type],
                            :center => {:latitude => -33.947, :longitude => 18.462},
                            :zoom => 12)

      map.click do |script, location|
        marker = map.add_marker :location => location
        # marker.open_info_window :url => {:action => :show_location_info}
        marker.click do |script, location|
          marker.open_info_window :location => location, :url => {:action => :show_location_info}
        end
      end
      
      marker = map.add_marker :location => {:latitude => -33.947, :longitude => 18.462},
                              :tooltip => {:text => 'This is sparta!', :show => :on_mouse_hover},
                              :circle => {:radius => 10, :border_width => 5}
       marker.click do |script, location|
         script << ajax_request
         marker.open_info_window(:location => location,
                                 :partial => 'spot_information',
                                 :locals => {:information => "this is really interesting"})
       end
      
      

      polygon = map.add_polygon :vertices => [[-33.901, 18.409],
                                              [-33.921, 18.447],
                                              [-33.942, 18.425],
                                              [-33.919, 18.390],
                                              [-33.901, 18.409]],
                                :tooltip => {:text => 'This is a cape town!',
                                :show => :on_mouse_hover}

      gravatar_marker = map.add_marker :location => {:latitude => -34, :longitude => 18.5},
                                       :gravatar => {:email_address => 'email2ants@gmail.com',:size => 50}
    end
  end
  
  def ajax_request
    ajax = <<-SCRIPT
    new Ajax.Request('/map/info', { method: 'get', 
      onSuccess: function(transport) {
          alert(transport.responseText);
      }
    });
    SCRIPT
  end
    
end
