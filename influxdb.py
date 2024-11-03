import influxdb_client, os, time
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

token = "Zvp2TacGtUKjYcAl0oadtD8V3vc8pJ2N-7fOfjfwyI41uSfmytMrYNqo9LDzvnj9pk68x68rHQmenKdRjfzeUA=="
org = "ZenTrack"
url = "http://localhost:8080"

write_client = influxdb_client.InfluxDBClient(url=url, token=token, org=org)

bucket = "dev"

write_api = write_client.write_api(write_options=SYNCHRONOUS)

query_api = write_client.query_api()

values =[ [90, 92, 97, 104, 109, 115, 120, 123, 127, 130],[88,91,93,96,100,104,107,110,113,116],[85,88,91,94,97,100,103,106,109,112],[80,83,86,89,92,95,98,101,104,107],[75,78,81,84,87,90,93,96,99,102]]

nom = ["John", "Paul", "George", "Ringo", "Yoko"]

for name, value_list in zip(nom, values):
    for value in value_list:
        point = Point("data") \
            .tag("users", name) \
            .field("BPM", value) \
            .time(time.time_ns(), WritePrecision.NS)

        write_api.write(bucket=bucket, org=org, record=point)
        time.sleep(1)  # Espacement de 1 seconde entre les points



#Lecture
query = """from(bucket: "dev")
  |> range(start: -10m)
  |> filter(fn: (r) => r._measurement == "data")
  |> mean()"""
tables = query_api.query(query, org="ZenTrack")

for table in tables:
    for record in table.records:
        print(record)

