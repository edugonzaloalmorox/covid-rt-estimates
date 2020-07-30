#!/bin/bash

# Array of all targets to update
declare -a targets=(
  "R/update-cases.R"
  "R/update-deaths.R"
  "R/update-united-kingdom.R"
  "R/update-united-states.R"
  "R/update-russia.R"
  "R/update-italy.R"
  "R/update-germany.R"
  "R/update-brazil.R"
  "R/update-canada.R"
  "R/update-colombia.R"
  "R/update-india.R"
)

# Run each estimat in turn
for target in ${targets[@]}; do
  printf "\tRunning update for: %s \n" $target
  Rscript  $target
done