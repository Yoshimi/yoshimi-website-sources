# Yoshimi website sources

Markup, style data and media for the yoshimi website,
along with a few scripts for generation and deployment.

The website is built using [jinja](https://jinja.palletsprojects.com/en/stable/) templates and a simple build script,
and is deployed at https://yoshimi.github.io/ and https://yoshimi.sourceforge.io/.

## Prerequisites and configuration

Python 3.9 or higher is required to generate the site.

### Set up and activate the virtual environment

Run
```
python -m venv .venv
python -m pip install -r requirements.txt
. .venv/bin/activate
```

## Building

After activating the virtual environment, run:

```
./build.py
```

The generated site is now placed in the directory `site`.

## Overview of setup

The site is generated using `build.py` which bases it output solely on the data in the `src` directory.

### `src/pages`

Contains jinja templates that are rendered to static html.
Which pages are actually rendered is specified in `build.py`.

### `src/fragments`

Contains fragments or templates that are reused by inclusion. Currently only contains the main template used by all pages.

### `src/assets`

Subdirectories in this directory are copied directly to the root of the generated site.

### `src/data`

This directory should only contain yaml files containing data to be used in the page templates.
Each file should have one or more top level keys corresponding to the pages where the data under that key may be used.

In the following example, bar and baz can be used in the page named foo:
```yaml
foo:
  bar: 
    a: 42
    b: 96
  baz:
    - hello
    - world
```
The file names do not matter, only the top level keys.

⚠️ Keys are not merged deeply, so data used in one page cannot be split between different data files!

## Data & Assets from external sources

The user guide in `src/assets/docs/user-guide` is a copy from `doc/yoshimi_user_guide` which
should be updated on every release.

The version data in `src/data/version_data.yaml` is fetched using `git tag` in the yoshimi repo.

Yoshimi repo: https://github.com/Yoshimi/yoshimi


## Committing/Deploying

The site is deployed to both github pages and sourceforge.

## Sourceforge

The `deploy_sf.sh` script generates a bundle based on the source
directory and uploads it to sourceforge. 
See the script header for details.

## Github pages

The deployment to yoshimi.github.io is made using Github Actions.
See `.github/workflows/build-and-deploy.yaml` in this repo.