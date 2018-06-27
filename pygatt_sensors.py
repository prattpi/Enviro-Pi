#!/usr/bin/python3

from sqlalchemy import text, exc, table, insert, create_engine
import pygatt
from binascii import hexlify
import time
from datetime import datetime
import subprocess
from configparser import ConfigParser

# Uncomment for BLE debugging
#import logging
#logging.basicConfig()
#logging.getLogger('pygatt').setLevel(logging.DEBUG)

def get_reading(adapter,DEVICE,temp_handle,humid_handle=None):
   print("Connecting to device: "+DEVICE)
   # Vars to hold data
   data = {}
   HANDLES = {}
   HANDLES['temp_handle'] = temp_handle
   if humid_handle is not None: 
      HANDLES['humid_handle'] = humid_handle
   print(HANDLES)
   # Connect to device (try a few times, this can be finicky)
   ADDRESS_TYPE = pygatt.BLEAddressType.random
   for attempt in range(5):
      try:
         adapter.start()
         device = adapter.connect(DEVICE, address_type=ADDRESS_TYPE)
         print("Connection successful!")
         for handle_type, handle in HANDLES.items():
            value = device.char_read(handle)
            print("Retrieved value:")
            print(value)
            data_value = format_data(DEVICE, value)
            data[handle_type]=data_value
         break
      except Exception as e: 
         print(e)
         print("Connection try #"+str(attempt+1)+" failed, waiting to try again...")
         time.sleep(5)
         #continue
      else:
         print("Finished device, disconnecting and stopping adapter...")
         device.disconnect()
         adapter.stop()
         time.sleep(5)
   else:
      print("Connection failed for device: "+DEVICE)
   # return data
   return data

def format_data(DEVICE, stored_data):
   # Format data per device specifics
   data_value = float(stored_data.decode())
   return data_value

def create_connection(db,un,pw,host):
   try:
      #                      dialect+driver://username:password@host:port/database
      engine = create_engine('mysql+pymysql://'+un+':'+pw+'@'+host+'/'+db)
      return engine
   except Error as e:
      print(e)
      return None

########
# main #
########

def main():
   # configuration ini file path
   config_file = "/home/pi/enviropi/pygatt_sensors.ini"

   # Read config file in
   config = ConfigParser()
   config.read(config_file)
   db = config.get('DATABASE', 'db_name')
   un = config.get('DATABASE', 'username')
   pw = config.get('DATABASE', 'password')
   host = config.get('DATABASE', 'host')

   # Read device(s) configuration
   DEVICES = {}
   sections = config.sections()
   for section in sections:
      if section.startswith('DEVICE'):
         DEVICES[section] = dict(config.items(section))

   # Start BLE adapter and get available devices
   print("Scanning for devices...")  
   adapter = pygatt.GATTToolBackend()
   adapter.start()
   available_devices = adapter.scan(run_as_root=True, timeout=5)
   found_list = []
   for devicefound in available_devices:
      found_list.append(devicefound['address'])
   adapter.stop()

   # Attempt reading 
   for device,attributes in DEVICES.items():
      device_hwadd=attributes['address']
      sensor_id=attributes['sensor_id']
      print("Scanning for "+device+" at "+device_hwadd)
      if device_hwadd.upper() in found_list:
         print("Found "+device_hwadd+", continuing...")
      else:
         print("Device "+device_hwadd+" not available, skipping it...")
         continue 

      # Read data from handle(s)
      results = get_reading(adapter,device_hwadd,attributes.get('temp_handle'),attributes.get('humid_handle'))
      print(results)

      # create connection and write reading to db as long as temp is non-null
      if results.get('temp_handle'):
         time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
         engine = create_connection(db,un,pw,host)
         result = engine.execute('INSERT INTO reading (device_address,sensor_id,temp_f,rh,reading_dt) '
                        'VALUES ("'+str(device_hwadd)+'","'+str(sensor_id)+'",'+str(results.get('temp_handle','NULL'))+','+str(results.get('humid_handle','NULL'))+',"'+time+'")')
         print("Successfully added new row")
      else:
         print("Skipping db write as no data retrieved")
   exit(1)

if __name__ == '__main__':
   main()
