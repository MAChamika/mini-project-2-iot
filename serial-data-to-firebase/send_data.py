import firebase_admin
from firebase_admin import credentials, db
import time
import serial

# Set the path to your Firebase credentials JSON file
cred = credentials.Certificate("credential.json")

try:
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://health-check-48e20-default-rtdb.firebaseio.com'
    })
except Exception as e:
    print("Firebase initialization error:", e)
    exit()

ref = db.reference('/user_data')
allset = db.reference('/')
humidity = []
temperature = []
i = 0
ser = serial.Serial('\\\\.\\COM5', 9600)

while True:
    try:
        data = ser.readline().decode().strip()
        user_input = float(data)
        i += 1
        timestamp = int(time.time() * 1000)  # Convert to milliseconds
        

        if (i % 2) != 0:
            humidity_data = {
                'timestamp': timestamp,
                'humidity': user_input,  # Store only humidity value
            }
            humidity.append(humidity_data)
            print(humidity_data)
        else:
            temp_data = {
                'timestamp': timestamp,
                'temperature': user_input,  # Store only humidity value
            }
            temperature.append(temp_data)
            print(temp_data)

        allset.child('humidity').set(humidity)
        allset.child('temperature').set(temperature)

        time.sleep(1)

    except ValueError as ve:
        print("Error parsing data:", ve)
    except Exception as e:
        print("Unknown error:", e)
