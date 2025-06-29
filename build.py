import argparse
import os
from jinja2 import Environment, FileSystemLoader
from yaml import load, SafeLoader
import shutil
from pathlib import Path

import datetime


def menu_item(title, filename):
    """Helper function for the data underlying the header and footer menus"""
    return {"title": title, "page": filename}


FOOTER_ITEMS = [
    menu_item("About", "about"),
    menu_item("History", "history"),
    menu_item("People", "people"),
    menu_item("Contact", "contact"),
]

NAV_ITEMS = [
    menu_item("Home", "index") | {"alt_url": "./"},
    menu_item("Downloads", "downloads"),
    menu_item("Screenshots", "screenshots"),
    menu_item("Demos", "demos"),
    menu_item("Help", "help"),
]

# Data that can be used in any template
ENV_GLOBALS = {
    "footer_links": FOOTER_ITEMS,
    "nav_links": NAV_ITEMS,
    "updated": datetime.date.today().isoformat(),
}


PAGES = [
    ("index", {}),
    ("about", {}),
    ("contact", {}),
    ("demos", {}),
    ("downloads", {}),
    ("help", {}),
    ("history", {}),
    ("people", {}),
    ("screenshots", {}),
]


def parse_args():
    parser = argparse.ArgumentParser(description="Generates the static yoshimi site.")
    parser.add_argument(
        "-o",
        "--output",
        default="site",
        help="Output directory for generated site (default: site)",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    env = Environment(loader=FileSystemLoader("./src"))

    extra_data = {}
    for data_file in os.listdir("./src/data"):
        with open(f"./src/data/{data_file}") as f:
            extra_data.update(load(f, Loader=SafeLoader))

    env.globals.update(ENV_GLOBALS)
    if os.path.exists(args.output):
        shutil.rmtree(args.output)
    os.mkdir(args.output)

    for dir in os.listdir("./src/assets"):
        shutil.copytree(f"./src/assets/{dir}", f"{args.output}/{dir}")

    for page, data in PAGES:
        template = env.get_template(f"pages/{page}.html.jinja")
        data.update(extra_data.get(page, {}))
        with open(f"{args.output}/{page}.html", "w") as outputfile:
            outputfile.write(template.render(page=page, **data))


if __name__ == "__main__":
    main()
