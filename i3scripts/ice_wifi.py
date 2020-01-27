#!python
import datetime
import json
import requests
import sys

base = 'https://portal.imice.de/api1/rs/'

try:
    data_status = requests.get(base + 'status').json()
    data_trip = requests.get(base + 'tripInfo/trip').json()
except json.decoder.JSONDecodeError:
    print("[connected to ICE: error with json]")
    sys.exit()
except requests.exceptions.ConnectionError:
    print("[connected to ICE: error connecting to portal]")
    sys.exit()


def getit(stop_eva):
    for stop in data_trip['trip']['stops']:
        if stop['station']['evaNr'] == stop_eva:
            scheduledArrival = int(stop['timetable']['scheduledArrivalTime']) / 1000
            scheduledArrival_date = datetime.datetime.fromtimestamp(scheduledArrival)
            return "next: {} at {}{} on track {}".format(
                stop['station']['name'],
                scheduledArrival_date.strftime('%H:%M'),
                stop['timetable']['arrivalDelay'],
                stop['track']['actual'],
            )
    return


print(" [{}km/h, {} class, {}]".format(
    data_status["speed"],
    "2." if data_status["wagonClass"] == "SECOND" else "1.",
    getit(data_trip['trip']['stopInfo']['actualNext']),
))
