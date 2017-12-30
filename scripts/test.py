import json
import urllib.request
import os
import re
import app.aux as aux

os.environ['all_proxy'] = ""
os.environ['http_proxy'] = ""
os.environ['https_proxy'] = ""


def get_param_by_id(id, param="stops", index="routes"):
    # id = ids[0]
    id_fixed = aux.clean_chars(id)
    id_url = re.sub(r'\s', '%20', id)

    file_name = "data/{}/{}_{}.json".format(index, id_fixed, param)

    if os.path.exists(file_name):
        return

    url = "http://lima.api.tumicro.pe/otp/routers/lima/index/{}/{}/{}".format(index, id_url, param)
    content = ""
    try:
        with urllib.request.urlopen(url) as response:
            content = response.read().decode('utf8')
    except:
        print("Error!")

    if content == "":
        return

    with open(file_name, 'w') as f:
        f.write(content)
    return


if __name__ == "__main__":

    # index_file = r"data/routes.json"
    # index_file = r"data/stops.json"
    # index_file = r"data/patterns.json"

    # with open(index_file, 'r') as f:
    #     result = json.load(f)
    # ids = [elem['id'] for elem in result]

    trips = set()
    comp = set()
    dir = 'data/trips/'
    for file in os.listdir(dir):
        if not os.path.splitext(file)[0].endswith("_"):
            continue
        file_name = dir + file
        with open(file_name, 'r') as f:
            content = json.load(f)
            json_data = json.loads(content["route"]["desc"])
            comp.add(json_data.get("agency_name", ""))
        # for line in content:
        #     trips.add(line['id'])
    ids = list(trips)

    # with open('data/empresas.txt', 'w') as f:
    #     f.writelines("\n".join(list(comp)))

    # params = ['stops', 'patterns', 'trips']
    params = ['patterns', 'routes', 'stoptimes', 'transfers']
    # params = ['geometry','semanticHash','stops','trips']
    # params = ['geometry', 'semanticHash', 'stops']
    # params = [""]

    # index = "routes"
    index = "stops"
    # index = "patterns"
    # index = "trips"

    for id in ids:
        for param in params:
            print("id= {}; param={}".format(id, param))
            get_param_by_id(id, index=index, param=param)



