try {
jQuery(document).ready(function() {
window.onunload = GUnload;
if (GBrowserIsCompatible()) {
map_lines = new Array();
map = new GMap2(document.getElementById('map'));
track_bounds = new GLatLngBounds();
map.setCenter(new GLatLng(48.45, 8.43));
map.setZoom(4);
last_mouse_location = map.getCenter();
function map_mousemove(map){
return GEvent.addListener(map, "mousemove", function(location) {
last_mouse_location = location;
});
}
map_mousemove_event = map_mousemove(map);
map.addControl(new GSmallMapControl());
map.addControl(new GMapTypeControl());
function map_click(map){
return GEvent.addListener(map, "click", function(overlay, location) {
if(location){
marker = new GMarker(location, {draggable: false});
map.addOverlay(marker);
track_bounds.extend(marker.getLatLng());
function marker_click(marker){
return GEvent.addListener(marker, "click", function() {
jQuery.get('/map/show_location_info?location%5Blatitude%5D=' + marker.getLatLng().lat() + '&location%5Blongitude%5D=' + marker.getLatLng().lng() + '', function(data) {
marker.openInfoWindow("<div id='info_window_content'>" + data + "</div>");
});
});
}
marker_click_event = marker_click(marker);
}
});
}
map_click_event = map_click(map);
} else { alert('Your browser be old, it cannot run google maps!');}
})
function clear_map(){
jQuery(document).ready(function() {
window.onunload = GUnload;
if (GBrowserIsCompatible()) {
map.clearOverlays();
} else { alert('Your browser be old, it cannot run google maps!');}
})
}
} catch (e) { alert('RJS error:\n\n' + e.toString()); alert('jQuery(document).ready(function() {\nwindow.onunload = GUnload;\nif (GBrowserIsCompatible()) {\nmap_lines = new Array();\nmap = new GMap2(document.getElementById(\'map\'));\ntrack_bounds = new GLatLngBounds();\nmap.setCenter(new GLatLng(48.45, 8.43));\nmap.setZoom(4);\nlast_mouse_location = map.getCenter();\nfunction map_mousemove(map){\nreturn GEvent.addListener(map, \"mousemove\", function(location) {\nlast_mouse_location = location;\n});\n}\nmap_mousemove_event = map_mousemove(map);\nmap.addControl(new GSmallMapControl());\nmap.addControl(new GMapTypeControl());\nfunction map_click(map){\nreturn GEvent.addListener(map, \"click\", function(overlay, location) {\nif(location){\nmarker = new GMarker(location, {draggable: false});\nmap.addOverlay(marker);\ntrack_bounds.extend(marker.getLatLng());\nfunction marker_click(marker){\nreturn GEvent.addListener(marker, \"click\", function() {\njQuery.get(\'/map/show_location_info?location%5Blatitude%5D=\' + marker.getLatLng().lat() + \'&location%5Blongitude%5D=\' + marker.getLatLng().lng() + \'\', function(data) {\nmarker.openInfoWindow(\"<div id=\'info_window_content\'>\" + data + \"</div>\");\n});\n});\n}\nmarker_click_event = marker_click(marker);\n}\n});\n}\nmap_click_event = map_click(map);\n} else { alert(\'Your browser be old, it cannot run google maps!\');}\n})\nfunction clear_map(){\njQuery(document).ready(function() {\nwindow.onunload = GUnload;\nif (GBrowserIsCompatible()) {\nmap.clearOverlays();\n} else { alert(\'Your browser be old, it cannot run google maps!\');}\n})\n}'); throw e }