#!/bin/bash

# Dropped -k (= --convert-links) flag
# Dropped --adjust-extension flag
# Use root dir as root (instead of html)

wget --mirror \
    --page-requisites \
    --warc-file="nl-menu" \
    --warc-cdx \
    --output-file="nl-menu.log" \
    http://www.nl-menu.nl

