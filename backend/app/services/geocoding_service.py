import requests
import time
from typing import Optional, Tuple

class GeocodingService:
    @staticmethod
    def get_coordinates_free(address: str) -> Optional[Tuple[float, float]]:
        """
        Improved Nominatim service with better error handling and retry logic
        """
        try:
            # Try different variations of the address for better results
            address_variations = [
                address,
                f"{address}, India",  # Add country if not present
                address.replace("Bengaluru", "Bangalore"),  # Try common variant
            ]
            
            for addr in address_variations:
                result = GeocodingService._try_nominatim(addr)
                if result:
                    return result
                time.sleep(1)  # Rate limiting
            
            print(f"All geocoding attempts failed for: {address}")
            return None
                
        except Exception as e:
            print(f"Geocoding error: {e}")
            return None
    
    @staticmethod
    def _try_nominatim(address: str) -> Optional[Tuple[float, float]]:
        """Helper method to try geocoding with Nominatim"""
        try:
            url = "https://nominatim.openstreetmap.org/search"
            params = {
                'q': address,
                'format': 'json',
                'limit': 1,
                'addressdetails': 1
            }
            
            headers = {
                'User-Agent': 'TimeleftApp/1.0 (contact@example.com)'
            }
            
            response = requests.get(url, params=params, headers=headers, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            if data and len(data) > 0:
                lat = float(data[0]['lat'])
                lon = float(data[0]['lon'])
                return (lat, lon)
            
            return None
                
        except Exception as e:
            print(f"Nominatim request failed: {e}")
            return None