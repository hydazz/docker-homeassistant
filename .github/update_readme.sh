#!/bin/bash

sed -i -E \
	-e "s/home_assistant-.*?-41BDF5/home_assistant-${APP_VERSION}-41BDF5/g" \
	README.md
