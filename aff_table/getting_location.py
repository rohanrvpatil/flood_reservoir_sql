import time
import googlemaps

def get_lat_lng(site_name, district_name, state_name, country="India"):
    api_key = "AIzaSyDQgsaZdEU-elx6jAGkUopVX5Jxf45sgy0"  # Replace with your API key
    gmaps = googlemaps.Client(key=api_key)
    query = f"{site_name}, {district_name}, {state_name}, {country}"
    
    try:
        geocode_result = gmaps.geocode(query)
        if geocode_result:
            location = geocode_result[0]['geometry']['location']
            return location['lat'], location['lng']
        else:
            print(f"Location not found for query: {query}")
            return None, None
    except Exception as e:
        print(f"Error: {e}")
        return None, None

# Example usage
site_name = "MATHANI ROAD BRIDGE"
district_name = "BALESHWAR"
state_name = "Odisha"

lat, lng = get_lat_lng(site_name, district_name, state_name)

print(f"Latitude: {lat}, Longitude: {lng}")




#AIzaSyDQgsaZdEU-elx6jAGkUopVX5Jxf45sgy0