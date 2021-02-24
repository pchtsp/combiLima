import json
import urllib.request
import os
import re
import app.aux as aux
import pprint as pp
import urllib.parse
import shutil

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


def get_image(route_code, dir='shortName'):

    # route_code = "IO49"
    region = "Lima"
    server = 'http://image.tumicro.pe'
    url = "{}/{}/{}.jpg".format(server, region, urllib.parse.quote_plus(route_code))
    file_name = "data/img/{}/{}.jpg".format(dir, aux.clean_chars(route_code))

    content = ""
    try:
        with urllib.request.urlopen(url) as response:
            content = response.read()
    except:
        print("Error!")

    if content == "":
        return False

    with open(file_name, 'wb') as f:
        f.write(content)

    return True


def download_all_routes():
    file_name = 'data/routes.json'
    with open(file_name, 'r') as f:
        content = json.load(f)
        # json_data = json.loads(content["route"]["desc"])
        # comp.add(json_data.get("agency_name", ""))
    list = [r['longName'] for r in content]
    # list = [r['shortName'] for r in content]

    result = {}

    for l in list:
        result[l] = get_image(l, dir='longName')

    with open("data/log/results_longName.txt", 'w') as f:
        json.dump(result, f)


def download_trips():
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


if __name__ == "__main__":
    # download_all_routes()

    file_name = 'data/routes.json'
    with open(file_name, 'r') as f:
        content = json.load(f)
        # json_data = json.loads(content["route"]["desc"])
        # comp.add(json_data.get("agency_name", ""))

    list1 = [r['longName'] for r in content]
    list2 = [r['shortName'] for r in content]
    list1_list2 = {l1 + '.jpg': list2[pos] + '.jpg'
                   for pos, l1 in enumerate(list1)}

    dir = 'data/img/'
    for file in os.listdir(dir + 'longName/'):
        file_name = dir + 'longName/' + file
        new_file_name = dir + 'shortName_all/' + list1_list2[file]
        shutil.copy(file_name, new_file_name)


    pass


