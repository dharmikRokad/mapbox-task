#!/usr/bin/env python3
import json
import random
import string
import uuid
import math
from pathlib import Path

# Constants for the random shift (in km)
MIN_SHIFT_KM = 15
MAX_SHIFT_KM = 100

# Earth's radius in km
EARTH_RADIUS_KM = 6371.0

def shift_location(lat, lng, random_seed=None):
    """
    Shift a latitude/longitude coordinate by a random distance between
    MIN_SHIFT_KM and MAX_SHIFT_KM kilometers in a random direction.
    """
    if random_seed:
        random.seed(random_seed)
    
    # Random distance in km within our range
    distance_km = random.uniform(MIN_SHIFT_KM, MAX_SHIFT_KM)
    
    # Random bearing in radians
    bearing_rad = random.uniform(0, 2 * math.pi)
    
    # Convert lat/lng to radians
    lat_rad = math.radians(lat)
    lng_rad = math.radians(lng)
    
    # Calculate new position
    # Formula from: https://www.movable-type.co.uk/scripts/latlong.html
    angular_distance = distance_km / EARTH_RADIUS_KM
    
    new_lat_rad = math.asin(
        math.sin(lat_rad) * math.cos(angular_distance) +
        math.cos(lat_rad) * math.sin(angular_distance) * math.cos(bearing_rad)
    )
    
    new_lng_rad = lng_rad + math.atan2(
        math.sin(bearing_rad) * math.sin(angular_distance) * math.cos(lat_rad),
        math.cos(angular_distance) - math.sin(lat_rad) * math.sin(new_lat_rad)
    )
    
    # Convert back to degrees
    new_lat = math.degrees(new_lat_rad)
    new_lng = math.degrees(new_lng_rad)
    
    return new_lat, new_lng

def generate_fake_id():
    """Generate a new random UUID"""
    return str(uuid.uuid4())

def generate_fake_string(length=10):
    """Generate a random string of a given length"""
    letters = string.ascii_letters + string.digits
    return ''.join(random.choice(letters) for _ in range(length))

def anonymize_visits(data):
    """Anonymize the visits data"""
    results = {"visits": []}
    
    # Use the same random seed to ensure consistent shifts
    random_seed = random.randint(1, 10000)
    
    for visit in data["visits"]:
        new_visit = {
            "id": generate_fake_id(),
            "geoLocation": {
                "latitude": None,
                "longitude": None,
                "__typename": visit["geoLocation"]["__typename"]
            },
            "__typename": visit["__typename"]
        }
        
        # Shift location
        if "geoLocation" in visit and visit["geoLocation"] is not None:
            lat = visit["geoLocation"]["latitude"]
            lng = visit["geoLocation"]["longitude"]
            new_lat, new_lng = shift_location(lat, lng, random_seed)
            new_visit["geoLocation"]["latitude"] = new_lat
            new_visit["geoLocation"]["longitude"] = new_lng
        
        results["visits"].append(new_visit)
    
    return results

def anonymize_stores(data):
    """Anonymize the stores data"""
    results = {"stores": []}
    
    # Use the same random seed to ensure consistent shifts
    random_seed = random.randint(1, 10000)
    
    for store in data["stores"]:
        new_store = {
            "id": generate_fake_id(),
            "__typename": store["__typename"]
        }
        
        # Copy over numeric data (with slight variations)
        if "caseVolumeLTM" in store and store["caseVolumeLTM"] is not None:
            new_store["caseVolumeLTM"] = round(store["caseVolumeLTM"] * random.uniform(0.85, 1.15), 1)
        else:
            new_store["caseVolumeLTM"] = None
            
        if "caseVolume2024" in store and store["caseVolume2024"] is not None:
            new_store["caseVolume2024"] = round(store["caseVolume2024"] * random.uniform(0.85, 1.15), 1)
        else:
            new_store["caseVolume2024"] = None
            
        if "cirocCases" in store and store["cirocCases"] is not None:
            new_store["cirocCases"] = round(store["cirocCases"] * random.uniform(0.85, 1.15), 6)
        else:
            new_store["cirocCases"] = None
            
        if "percentile" in store and store["percentile"] is not None:
            # Keep percentile within 0-100 range
            varied = store["percentile"] * random.uniform(0.85, 1.15)
            new_store["percentile"] = min(100, max(0, varied))
        else:
            new_store["percentile"] = None
        
        # Shift location
        new_store["geoLocation"] = {
            "latitude": None,
            "longitude": None,
            "__typename": "Point"
        }
        
        if "geoLocation" in store and store["geoLocation"] is not None:
            lat = store["geoLocation"]["latitude"]
            lng = store["geoLocation"]["longitude"]
            new_lat, new_lng = shift_location(lat, lng, random_seed)
            new_store["geoLocation"]["latitude"] = new_lat
            new_store["geoLocation"]["longitude"] = new_lng
        
        results["stores"].append(new_store)
    
    return results

def anonymize_customers(data):
    """Anonymize the customers data"""
    results = {"customers": []}
    
    # Use the same random seed to ensure consistent shifts
    random_seed = random.randint(1, 10000)
    
    # Create a tracking dictionary to ensure same original ID always maps to same anonymized ID
    id_mapping = {}
    
    for customer in data["customers"]:
        new_customer = {
            "__typename": customer.get("__typename", "Customer")
        }
        
        # Process ID consistently
        if "id" in customer:
            if customer["id"] in id_mapping:
                new_customer["id"] = id_mapping[customer["id"]]
            else:
                new_id = generate_fake_id()
                id_mapping[customer["id"]] = new_id
                new_customer["id"] = new_id
        
        # Process name fields if they exist
        if "name" in customer and customer["name"]:
            # Keep same length but randomize
            name_parts = customer["name"].split() if customer["name"] else []
            if len(name_parts) >= 2:
                new_customer["name"] = f"{generate_fake_string(len(name_parts[0]))} {generate_fake_string(len(name_parts[1]))}"
            else:
                new_customer["name"] = generate_fake_string(len(customer["name"]))
        else:
            new_customer["name"] = None
            
        if "firstName" in customer and customer["firstName"]:
            new_customer["firstName"] = generate_fake_string(len(customer["firstName"]))
        elif "firstName" in customer:
            new_customer["firstName"] = None
            
        if "lastName" in customer and customer["lastName"]:
            new_customer["lastName"] = generate_fake_string(len(customer["lastName"]))
        elif "lastName" in customer:
            new_customer["lastName"] = None
        
        # Process email if it exists
        if "email" in customer and customer["email"]:
            parts = customer["email"].split('@')
            if len(parts) == 2:
                domain_parts = parts[1].split('.')
                if len(domain_parts) >= 2:
                    new_customer["email"] = f"{generate_fake_string(len(parts[0]))}@{generate_fake_string(len(domain_parts[0]))}.{domain_parts[1]}"
                else:
                    new_customer["email"] = f"{generate_fake_string(len(parts[0]))}@{generate_fake_string(len(parts[1]))}"
            else:
                new_customer["email"] = generate_fake_string(len(customer["email"]))
        elif "email" in customer:
            new_customer["email"] = None
        
        # Process phone if it exists
        if "phone" in customer and customer["phone"]:
            # Keep the same format but replace digits
            new_phone = ""
            for char in customer["phone"]:
                if char.isdigit():
                    new_phone += str(random.randint(0, 9))
                else:
                    new_phone += char
            new_customer["phone"] = new_phone
        elif "phone" in customer:
            new_customer["phone"] = None
        
        # Shift geolocation if it exists
        if "geoLocation" in customer and customer["geoLocation"]:
            new_customer["geoLocation"] = {
                "__typename": customer["geoLocation"].get("__typename", "Point")
            }
            
            if "latitude" in customer["geoLocation"] and "longitude" in customer["geoLocation"]:
                lat = customer["geoLocation"]["latitude"]
                lng = customer["geoLocation"]["longitude"]
                
                if lat is not None and lng is not None:
                    new_lat, new_lng = shift_location(lat, lng, random_seed)
                    new_customer["geoLocation"]["latitude"] = new_lat
                    new_customer["geoLocation"]["longitude"] = new_lng
                else:
                    new_customer["geoLocation"]["latitude"] = None
                    new_customer["geoLocation"]["longitude"] = None
        elif "geoLocation" in customer:
            new_customer["geoLocation"] = None
        
        # Copy other fields with appropriate anonymization
        for key, value in customer.items():
            if key not in new_customer and key not in ["id", "name", "firstName", "lastName", "email", "phone", "geoLocation"]:
                if isinstance(value, str):
                    # Anonymize strings unless they are type names or special values
                    if key == "__typename" or value in [None, ""]:
                        new_customer[key] = value
                    else:
                        new_customer[key] = generate_fake_string(len(value))
                elif isinstance(value, (int, float)):
                    # Vary numeric values slightly
                    new_customer[key] = value * random.uniform(0.85, 1.15)
                else:
                    # Just copy other values (null, boolean, etc.)
                    new_customer[key] = value
        
        results["customers"].append(new_customer)
    
    return results

def main():
    # Process visits.json
    try:
        with open('visits.json', 'r') as file:
            visits_data = json.load(file)
        
        anonymized_visits = anonymize_visits(visits_data)
        
        with open('anonymized_visits.json', 'w') as file:
            json.dump(anonymized_visits, file, indent=2)
        
        print("Successfully anonymized visits.json to anonymized_visits.json")
    except Exception as e:
        print(f"Error processing visits.json: {e}")
    
    # Process stores.json
    try:
        with open('stores.json', 'r') as file:
            stores_data = json.load(file)
        
        anonymized_stores = anonymize_stores(stores_data)
        
        with open('anonymized_stores.json', 'w') as file:
            json.dump(anonymized_stores, file, indent=2)
        
        print("Successfully anonymized stores.json to anonymized_stores.json")
    except Exception as e:
        print(f"Error processing stores.json: {e}")
    
    # Process customers.json
    try:
        with open('customers.json', 'r') as file:
            customers_data = json.load(file)
        
        anonymized_customers = anonymize_customers(customers_data)
        
        with open('anonymized_customers.json', 'w') as file:
            json.dump(anonymized_customers, file, indent=2)
        
        print("Successfully anonymized customers.json to anonymized_customers.json")
    except Exception as e:
        print(f"Error processing customers.json: {e}")

if __name__ == "__main__":
    main() 