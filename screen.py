from sqlalchemy import *
from configparser import ConfigParser
from tkinter import *
import os
from subprocess import check_output
import requests

class Application(object):
    def __init__(self, event=None):
        self.root = Tk()
        self.root.attributes("-fullscreen", True) # run fullscreen
        self.root.wm_attributes("-topmost", True) # keep on top
        #self.root.configure(padx=10, pady=10)
        self.root.title("EnviroPi")

        # Make the 3 columns take up the whole screen width
        Grid.columnconfigure(self.root, 0, weight=1)
        Grid.columnconfigure(self.root, 1, weight=1)
        Grid.columnconfigure(self.root, 2, weight=1)

        # Heading and IP address
        self.welcome = Label(self.root, text="EnviroPi", font=("Helvetica", 32)).grid(row=0,columnspan=3)
        ips = check_output(['hostname', '--all-ip-addresses'])
        ips = ips.strip()
        if ips:
            self.addr = Label(self.root, text=ips, font=("Helvetica", 28)).grid(row=1,columnspan=3)
        else:
            self.addr = Label(self.root, text="*No network connection*", fg="red", font=("Helvetica", 22)).grid(row=1,columnspan=3)

        # Recent data report - get data from MySQL
        config_file = "/home/pi/enviropi/pygatt_sensors.ini"
        config = ConfigParser()
        config.read(config_file)
        db = config.get('DATABASE', 'db_name')
        un = config.get('DATABASE', 'username')
        pw = config.get('DATABASE', 'password')
        host = config.get('DATABASE', 'host')
        self.engine = create_connection(db,un,pw,host)

        # Get the latest data and output data rows and refresh button
        self.refresh_data()

        # Control buttons
        self.button = Button(self.root, text="Quit", font=("Helvetica", 20), pady=10, highlightbackground="gray48", command=self.quit).grid(row=5,column=0,sticky=E)
        self.button2 = Button(self.root, text="Shutdown", font=("Helvetica", 20), pady=10, highlightbackground="gray48", command=self.shutdown).grid(row=5,column=1,sticky=E)
        self.button3 = Button(self.root, text="Restart", font=("Helvetica", 20), pady=10, highlightbackground="gray48", command=self.restart).grid(row=5,column=2)
    def quit(self, event=None):
        self.root.destroy()
    def refresh_data(self):
        print("Refreshing data...")
        query = "SELECT last_temp_f, last_rh, last_reading_dt FROM summaryData"
        result = self.engine.execute(query)
        values = result.fetchone()
        self.lread = Label(self.root, text="Last reading: "+str(values["last_reading_dt"]), pady=20, font=("Helvetica", 16)).grid(row=2,columnspan=3)
        self.tmp = Label(self.root, text=str(values["last_temp_f"])+" F", font=("Helvetica", 20)).grid(row=3,column=1)
        self.hmd = Label(self.root, text=str(values["last_rh"])+" % RH", pady=5, font=("Helvetica", 20)).grid(row=4,column=1)
        self.rf = Button(self.root, text="Refresh", font=("Helvetica", 20), pady=10, highlightbackground="gray48", command=self.refresh_data).grid(row=3,column=2,rowspan=2)
    def shutdown(self):
        os.system("sudo shutdown -h now")
    def restart(self):
        os.system("sudo reboot")

def create_connection(db,un,pw,host):
    try:
        #                      dialect+driver://username:password@host:port/database
        engine = create_engine('mysql+pymysql://'+un+':'+pw+'@'+host+'/'+db)
        return engine
    except Error as e:
        print(e)
        return None

app=Application()

mainloop()




