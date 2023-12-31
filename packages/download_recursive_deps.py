import os
import json
import requests
from debian.debfile import DebFile
from typing import Set
import argparse

# Directory for downloaded files
download_dir = "./downloaded/"
if not os.path.exists(download_dir):
    os.makedirs(download_dir)

# Load URLs from json file
with open('deb_urls.json', 'r') as file:
    deb_urls = json.load(file)

def find_url_of_dependency(dependency_name):
    # Match the exact name up to the first underscore.
    # For example: libc6 will match:
    # libc6_2.19-18+deb8u7_i386.deb
    # and won't match:
    # libc6-dev_2.19-18+deb8u7_i386.deb
    matches = [url for url in deb_urls if url.split('/')[-1].split('_')[0] == dependency_name]

    if len(matches) > 1:
        # Sort matches in descending lexicographical order
        matches.sort(reverse=True)
        # Warn about multiple matches and choosing the highest lexicographical match
        print(f"Warning: Multiple matches found for {dependency_name}. Choosing the highest lexicographical match.")
        for match in matches:
            print(match)
        print(f"Chosen: {matches[0]}")
        return matches[0]
    elif not matches:
        raise ValueError(f"No match found for {dependency_name}")

    return matches[0]

def fetch_dependency(dep_name, visited: Set[str]) -> [str]:
    url = find_url_of_dependency(dep_name)
    if url in visited:
        print(f"{dep_name} already fetched")
        return []
    visited.add(url)
    response = requests.get(url)
    file_name = url.split('/')[-1]
    file_path = os.path.join(download_dir, file_name)
    if os.path.isfile(file_path):
        print(f"{file_name} already exists")
    else:
        with open(file_path, 'wb') as file:
            file.write(response.content)

    deb = DebFile(file_path)
    # Use get() to retrieve 'Depends' value or None if key doesn't exist
    dependencies = deb.debcontrol().get('Depends')

    if dependencies:
        return dependencies.split(', ')
    else:
        print(f"{dep_name} has no dependencies")
        return []

def fetch_dependencies_recursive(initial_name, visited = None):
    print(f"Fetching: {initial_name}")
    if visited is None:
        visited = set()
    dependencies = fetch_dependency(initial_name, visited)
    for dep in dependencies:
        # Assuming the first part is the package name
        dep_name = dep.split(' ')[0]
        fetch_dependencies_recursive(dep_name, visited)

def main():
    parser = argparse.ArgumentParser(description="Fetch dependencies for given Debian packages.")
    parser.add_argument('packages', nargs='+', help='List of Debian packages to fetch dependencies for')
    args = parser.parse_args()

    for package_name in args.packages:
        fetch_dependencies_recursive(package_name)

if __name__ == "__main__":
    main()
