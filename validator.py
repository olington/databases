import sys
import jsonschema
from jsonschema import validate
import json

def report(err):
    f = open("log_err.txt", "w")
    f.write(err)
    f.close()

n = len(sys.argv)

data_file = "check1.json"
schema_file = "schemaSub.json"
report('')

try:
    with open(data_file, "r") as read_file:
        data = json.load(read_file)
except Exception as err:
    print("data_file error \'", data_file, "\'", sep='')
    report(str(err))
    exit()

try:
    with open(schema_file, "r") as read_schema:
        schema = json.load(read_schema)
except Exception as err:
    print("schema_file error \'", schema_file, "\'", sep='')
    report(str(err))
    exit()

print("Validating the input data using JSON-schema:")
try:
    validate(instance=data, schema=schema)
    print("Correct data")
except jsonschema.exceptions.ValidationError as ve:
    print("Error")
    report(str(ve))
