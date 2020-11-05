#' requires

if (!exists("DATAVERSE_KEY", mode = "function")
  & file.exists(here::here("data/runtime", "config.R"))) source(here::here("data/runtime", "config.R"))

if (!exists("DATAVERSE_KEY", mode = "function")) source(here::here("data/runtime", "config.R"))

#' Cache to save re-loading
cfid_existing_dataset <- list(name = "", dataset = list())

#' check_for_existing_id
#' try to find an existing dataset using the dataset_name as an id in the keywords
#' @param dataset_name string name for dataset (checked as a keyword on the published datasets to find a match)
#' @param use_cache Bool check the local cache for dataset name before retrieving it.
#' @return NA | List of full dataverse contents
check_for_existing_id <- function(dataset_name, use_cache = TRUE) {
  #check cache
  if (use_cache && cfid_existing_dataset$name == dataset_name) {
    return(cfid_existing_dataset$dataset)
  }
  # load existing
  existing_datasets <-
    dataverse::dataverse_contents(DATAVERSE_VERSEID, key = DATAVERSE_KEY, server = DATAVERSE_SERVER)
  existing <- NA
  for (existing_dataset in existing_datasets) {
    # deaccessed datasets are not accessible anymore - they can be skipped over but you can't test
    # for them from the data returned in the contents. Best I can find is they just 404 when you
    # load them. :(
    full_dataset <- tryCatch(dataverse::get_dataset(existing_dataset$id),
                             error = function(c) {
                               NA
                             }
    )
    if (!is.list(full_dataset)) {
      next
    }
    # for some reason the metadata keywords are inside the citation bcollate_derivative(COLLATED_DERIVATIVES[[1]])lock... go figure
    # loop over them looking for the keyword value and then check if it's the name of the dataset.
    for (metadata in full_dataset$metadataBlocks$citation$fields$value) {
      if (is.data.frame(metadata) &&
        "keywordValue" %in% names(metadata) &&
        dataset_name %in% metadata$keywordValue$value) {
        existing <- full_dataset
        break
      }
    }
    if (is.list(existing)) {
      break
    }
  }
  # save the outcome in the cache
  cfid_existing_dataset$name <<- dataset_name
  cfid_existing_dataset$dataset <<- existing
  return(existing)
}

#' get_latest_source_data_date
#' @param name string dataset name
#' @returns Date|NA of end of collection data from the dataset metadata
get_latest_source_data_date <- function(dataset_name) {
  existing <- check_for_existing_id(dataset_name)
  if (is.list(existing)) {
    date_of_collection_list <- lapply(existing$metadataBlocks$citation$fields$value, function(x) { if (is.data.frame(x) && exists("dateOfCollectionEnd", x)) { return(x) } })
    date_of_collection_list[sapply(date_of_collection_list, is.null)] <- NULL
    # test only 1 row
    if (length(date_of_collection_list) == 1) {
      date_of_collection <- date_of_collection_list[[1]]
      end_date <- as.Date(date_of_collection$dateOfCollectionEnd$value, format = "%Y-%m-%d")
      return(end_date)
    }
  }
  return(NA)
}

#' set_dataverse_envs
#' if configured primes the system environment with the server / key credentials for dataverse
set_dataverse_envs <- function() {
  if (exists("DATAVERSE_SERVER") && exists("DATAVERSE_KEY")) {
    Sys.setenv("DATAVERSE_SERVER" = DATAVERSE_SERVER)
    Sys.setenv("DATAVERSE_KEY" = DATAVERSE_KEY)
  }
}