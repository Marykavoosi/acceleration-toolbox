name: Make me a nice webpage    # can be whatever, but always nice to name your stuff

on:                       # when should this action be performed? 
  push:                   # 1. when code is pushed normally (add, commit, push)
    branches: [ main ]    # to 'main' branch
  pull_request:           # 2. or when code is pushed through a pull request
    branches: [ main ]    # to 'main' branch

jobs:                     # the stuff that will be performed
  build:                  # first job - build an archive that can be provided as input to GH pages
    runs-on: ubuntu-latest          # the actions will be running in a VM running Linux Ubuntu
    steps:                          # the steps of the job: check the repo code, build the artifact/archive, and upload it
    - uses: actions/checkout@v4     # checks out the code on your repo
    - uses: wranders/markdown-to-pages-action@v1     # this is a tool developed to render Markdown into a GH page
      with:
        token: ${{ secrets.GITHUB_TOKEN }}    # don't mind this, GH needs secrets, and has this as a default one. Just copy/paste, no need to generate a token... for now
        files: |-                   # the Markdown file to use
          README.md
    - uses: actions/upload-pages-artifact@v3    # packages the website into an artifact (like a zip/tar) that can be deployed as a GH page
      with:
        path: dist        # I don't know what this is

  deploy:
    runs-on: ubuntu-latest    # the website will be deployed in ubuntu
    needs: build              # it needs the artifact from the 'build' step, so that step must run first
    permissions:              # "Grant GITHUB_TOKEN the permissions required to make a Pages deployment" ¯\_(ツ)_/¯
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}   # I don't think this can be changed to another value, but ppl have discussed it: https://github.com/orgs/community/discussions/37267
    steps:                     # only step is to unpack the artifact, and present the code at the given location
    - uses: actions/deploy-pages@v4
      id: deployment
