from flask import Flask, request, jsonify
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
import requests
import uuid
# import time

# time.sleep(30)

# Configuration InfluxDB
INFLUXDB_URL = "http://localhost:8086"
INFLUXDB_TOKEN = "GCKgGGeGbZbtzLDTLXaEiwku6Ia9vFDRO7s4IzY0MsAGfimjT1yL6BSx7lSePkfB"
INFLUXDB_ORG = "Zentrack"
INFLUXDB_BUCKET = "dev"

# Configuration ACME
ACME_URL = "http://localhost:8080"  # Adresse de votre CSE ACME
ACME_ORIGIN = "CAdmin"  # Originator utilisé pour ACME

app = Flask(__name__)

# Initialisation d'InfluxDB
client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
write_api = client.write_api(write_options=SYNCHRONOUS)

@app.route('/notification', methods=['POST'])
def notification():
    data = request.json
    if "m2m:sgn" in data and "nev" in data["m2m:sgn"]:
        content = data["m2m:sgn"]["nev"]["rep"]["m2m:cin"]["con"]
        cin_ri = data["m2m:sgn"]["nev"]["rep"]["m2m:cin"]["ri"]  # Resource ID du CIN

        # Parse les données envoyées
        try:
            parsed_data = eval(content)  # Remplacez eval() par json.loads() si vous recevez un JSON valide
            watch_id = parsed_data.get("id", "unknown_watch")
            data_id = parsed_data.get("idData", "unknown_data")
            date = parsed_data.get("Date", "Unknown")
            temperature = float(parsed_data.get("Temperature", 0.0))
            humidity = float(parsed_data.get("Humidity", 0.0))
            pressure = float(parsed_data.get("Pressure", 0.0))
            heart_rate = float(parsed_data.get("HeartRate", 0.0))

            # Prépare un point pour InfluxDB
            point = (
                Point("environmental_data")
                .tag("id", watch_id)  # Ajout de l'identifiant de la montre en tag
                .tag("idData", data_id)  # Ajout de l'identifiant des données en tag
                .field("temperature", temperature)
                .field("humidity", humidity)
                .field("pressure", pressure)
                .field("heart_rate", heart_rate)
                .time(date)  # Date en ISO 8601 ou timestamp
            )
            # Écrit les données dans InfluxDB
            write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=point)
            print(f"Données insérées dans InfluxDB : {point}")

            # Supprime le CIN après écriture dans InfluxDB
            delete_cin(cin_ri)

            return jsonify({"status": "Data received, stored, and CIN deleted"}), 200

        except Exception as e:
            print(f"Erreur lors du traitement des données : {e}")
            return jsonify({"status": "Error processing data"}), 400
    else:
        return jsonify({"status": "Invalid data format"}), 400


def delete_cin(resource_id):
    """Supprime un CIN dans ACME."""
    try:
        headers = {
            "X-M2M-Origin": ACME_ORIGIN,
            "X-M2M-RI": str(uuid.uuid4()),
            "X-M2M-RVI": "3",
            "Content-Type": "application/json",
        }
        url = f"{ACME_URL}/{resource_id}"
        response = requests.delete(url, headers=headers)
        if response.status_code == 200:
            print(f"CIN supprimé avec succès : {resource_id}")
        else:
            print(f"Erreur lors de la suppression du CIN : {response.status_code}, {response.text}")
    except Exception as e:
        print(f"Erreur lors de la tentative de suppression du CIN : {e}")


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)