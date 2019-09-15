# Yoshimi website sources

Markup, style data and media for the yoshimi website,
along with a few scripts for generation and deployment.

## Building

Python 2.7+ (or 3.5+) is required to generate the site.

Run `./gen_site` in the _site directory to generate the site.
The resulting files will be placed in a directory called 'out'

If you want to write the output somewhere else, you can use the `BUILD_DIR`
environment variable, for example like this:
```
BUILD_DIR=/home/me/www/my_audio_websites/yoshimi/ ./gen_site
```
or
```
export BUILD_DIR=/home/me/www/my_audio_websites/yoshimi/
./gen_site
```
or
```
BUILD_DIR=.. ./gen_site
```

## Committing/Deploying

The site is deployed to both github pages and sourceforge.
There is one deployment script for each destination.

## Sourceforge

The `deploy_sf.sh` script generates a bundle based on the source
directory and uploads it to sourceforge. 
See the script header for details.

## Github pages

The `deploy_gh.sh` script stages a commit to the yoshimi.github.io repo with
the updated generated files. A clone of that repo must be present on the machine
running the script.
See the script header for details.
