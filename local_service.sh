#!/usr/bin/env bash

# The .env file must export secrets for local development, e.g.,
# export GUIDEBOOK_API_KEY="..."
source .env

# Force TZ, since info-beamer nodes always use UTC time.
INFOBEAMER_ENV_SERIAL=12345 TZ=UTC NODE=otakon25 SCRATCH=SCRATCH ./service
