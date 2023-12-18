import gzip
import requests
import json
import os

def download_packages_file(url, local_path):
    """Download the Packages.gz file."""
    response = requests.get(url, stream=True)
    try:
        os.remove(local_path)
    except FileNotFoundError:
        pass
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
    # List of Packages.gz URLs
    packages_urls = packages_urls = [
        # Jessie
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie/main/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie/contrib/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie/non-free/binary-i386/Packages.gz",

        # Jessie Backports
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-backports/main/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-backports/contrib/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-backports/non-free/binary-i386/Packages.gz",

        # Jessie Proposed Updates
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-proposed-updates/main/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-proposed-updates/contrib/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-proposed-updates/non-free/binary-i386/Packages.gz",

        # Jessie Updates
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-updates/main/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-updates/contrib/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/jessie-updates/non-free/binary-i386/Packages.gz",

        # Stretch
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/stretch/main/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/stretch/contrib/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/stretch/non-free/binary-i386/Packages.gz",

        # Sid
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/sid/main/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/sid/contrib/binary-i386/Packages.gz",
        "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/dists/sid/non-free/binary-i386/Packages.gz"
    ]
    base_url = "http://tagged.snapshots.deb.tails.boum.org/2.12/debian/"

    all_deb_urls = []

    for packages_url in packages_urls:
        print(f"Fetching {packages_url}")
        local_packages_path = "Packages.gz"
        
        # Download Packages.gz
        download_packages_file(packages_url, local_packages_path)

        # Parse the Packages file
        packages = parse_packages_file(local_packages_path)

        # Get .deb URLs
        deb_urls = get_deb_urls(packages, base_url)
        all_deb_urls.extend(deb_urls)

    # Save the URLs to a JSON file
    with open('deb_urls.json', 'w') as json_file:
        json.dump(all_deb_urls, json_file)

if __name__ == "__main__":
    main()
