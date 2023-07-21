#!/usr/bin/env python

# Very rudimentary helper script to pull all zones from an OctoDNS config
# file and run octodns-dump to generate zone files.
#
# This script IS NOT SMART.
#
# It assumes zone files shoud be written to the ./zones directory and
# only looks at the first target. It should be ehanced to properly
# parse an OctoDNS config file and behave reasonably.


import argparse
import subprocess
import yaml


def parse_yaml_file(file_path):
    with open(file_path, 'r') as file:
        try:
            data = yaml.safe_load(file)
            return data
        except yaml.YAMLError as e:
            print(f"Error parsing YAML file: {e}")


def run_octodns_dump(config_file_path, zone, target):
    command = ['octodns-dump', '--config-file', config_file_path, '--output-dir=./zones/', zone, target]
    print("Running command:", " ".join(command))
    subprocess.run(command)


def process_zones_elements(yaml_data):
    if 'zones' in yaml_data and isinstance(yaml_data['zones'], dict):
        for zone, zone_data in yaml_data['zones'].items():
            if 'targets' in zone_data and isinstance(zone_data['targets'], list) and zone_data['targets']:
                target = zone_data['targets'][0]
                run_octodns_dump(config_file_path, zone, target)
            else:
                print(f"No valid 'targets' list found for zone '{zone}'.")

    else:
        print("No 'zones' dictionary found in the YAML file or it is not a dictionary.")


# Create an argument parser
parser = argparse.ArgumentParser(description='Parse a YAML file and run octodns-dump with zone and the first target as command-line arguments.')

# Add the config file argument
parser.add_argument('--config-file', '-c', required=True, help='Path to the YAML config file')

# Parse the command-line arguments
args = parser.parse_args()

# Get the YAML file path from the command-line argument
config_file_path = args.config_file

# Parse the YAML file
yaml_data = parse_yaml_file(config_file_path)

# Process each 'zones' element and run octodns-dump with zone and the first target as command-line arguments
if yaml_data:
    process_zones_elements(yaml_data)



# Print contents of config-file for debugging
# print( yaml.dump(yaml_data) )
