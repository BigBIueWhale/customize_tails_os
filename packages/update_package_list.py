import gzip
import os
import requests
import json

def download_packages_file(url, local_path):
    """Download the Packages.gz file."""
    response = requests.get(url, stream=True)
    with open(local_path, 'wb') as f:
        for chunk in response.iter_content(chunk_size=1024):
            if chunk:  # Filter out keep-alive chunks
                f.write(chunk)

def parse_packages_file(file_path):
    """Parse the Packages.gz file to extract .deb URLs."""
    with gzip.open(file_path, 'rt', encoding='utf-8') as f:
        packages = []
        package = {}
        for line in f:
            if line == '\n':
                if package:  # End of a package entry
                    packages.append(package)
                    package = {}
            else:
                parts = line.split(':', 1)
                if len(parts) == 2:
                    key, value = parts
                    package[key.strip()] = value.strip()
        if package:  # Add the last package if exists
            packages.append(package)
    return packages

def get_deb_urls(packages, base_url):
    """Return a list of URLs for .deb files with i386 architecture."""
    deb_urls = []
    for package in packages:
        if package.get('Architecture') == 'i386' and package.get('Filename', '').endswith('.deb'):
            deb_urls.append(base_url + package['Filename'])
    return deb_urls

def main():
    # URL of the Packages.gz file
    packages_url = "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie/main/binary-i386/Packages.gz"
    local_packages_path = "Packages.gz"
    base_url = "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/"

    # Download Packages.gz
    download_packages_file(packages_url, local_packages_path)

    # Parse the Packages file
    packages = parse_packages_file(local_packages_path)

    # Get .deb URLs
    deb_urls = get_deb_urls(packages, base_url)

    # Save the URLs to a JSON file
    with open('deb_urls.json', 'w') as json_file:
        json.dump(deb_urls, json_file)

if __name__ == "__main__":
    main()
