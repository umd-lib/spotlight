# OAI-PMH Uploads

## Introduction

This Spotlight implementation has been configured to include the
"spotlight-oaipmh-resources" gem, to enable the import of items via
OAI-PMH harvesting.

This document provides application-specific information. For information about
the "spotlight-oaipmh-resources" gem itself, see the
<https://github.com/harvard-lts/spotlight-oaipmh-resources>  GitHub repository.

## Useful Resources

* Repository: <https://github.com/harvard-lts/spotlight-oaipmh-resources>
* Wiki: <https://github.com/harvard-lts/spotlight-oaipmh-resources/wiki>

## Database Migration Issue

After installing the "spotlight-oaipmh-resources" gem as outlined in the
installation steps below, an issue arose where the `rails db:migrate`
command failed because of a database migration within the
"spotlight-oaipmh-resources" gem. Specifically the
<https://github.com/harvard-lts/spotlight-oaipmh-resources/blob/v3.0.4/db/migrate/20220716014845_add_external_id_to_spotlight_resources.rb>
migration failed because the "spotlight_resources" table did not exist.

This appears to be caused by an ordering issue in the database migrations. In
the "spotlight-oaipmh-resources" gem, the migrations are dated *before* the
migrations for this application, and the migrations are run in timestamp order.

The workaround adopted for this implementation was to move the creation of
the "spotlight_resources" table into a
"db/migrate/19701231000000_create_spotlight_resources.rb", with a timestamp
of December 31, 1970, to place it before any other migration (December 31 was
chosen, instead of January 1, 1970, in case there is any need to place
additional migrations earlier).

It is not clear if a better way exists to fix this issue.

## Current Status

The "spotlight-oaipmh-resources" gem has been installed, and the functionality
is available under the "From external resource" tab in the "Add Items" panel
of the Spotlight administrative interface.

While the functionality is present, it has proven difficult to actually harvest
and data. The form has the following fields

* Type: A drop-down containing "MODS" and "Solr"
* Base URL: The base URL of the OAI-PMH endpoint
* Set Spec: The OAI-PMH set to harvest
* Select Mapping File: The mapping file to use in converting the OAI-PMH MODS
  data to the Spotlight Solr format

If a "Solr" type is selected, an additional field is displayed:

* Solr Query Filter

The "spotlight-oaipmh-resources" gem does not provide much documentation on how
to set these fields, or explicit examples.

Attempts were made to harvest data from DRUM, using the following fields:

| Field    | Value   |
| -------- | ------- |
| Type     | `MODS`  |
| Base URL | `https://api.drum.lib.umd.edu/server/oai/request/` |
| Set Spec | `com_1903_2224` |
| Select Mapping File | \<See below> |

### "Select Mapping" field

The "Select Mapping" field initially provides two options,
"Default Mapping File" and "New Mapping File". It is not clear what mapping
file the "Default Mapping File" option corresponds with.

The "New Mapping File" option requests an upload of a YAML file. The format
of the file is briefly described in
<https://github.com/harvard-lts/spotlight-oaipmh-resources/wiki>.

Attempts to create a mapping file that works with DRUM were unsuccessful. For
example, the following simple mapping file was attempted:

```zsh
- spotlight-field: unique-id_tesim
  mods:
      - path: recordInfo/recordIdentifier
- spotlight-field: full_title_tesim
  delimiter: ": "
  mods:
      - path: titleInfo
        delimiter: " "
        subpaths:
          - subpath: nonSort
          - subpath: title
```

This generated many errors in the SideKiq log of the form:

```text
E, [2024-03-07T15:53:44.430523 #6] ERROR -- : [ActiveJob] [Spotlight::Resources::PerformHarvestsJob] [24376609-2164-4022-a996-a777e5c3ae9f] 1- did not index successfully:
E, [2024-03-07T15:53:44.431422 #6] ERROR -- : [ActiveJob] [Spotlight::Resources::PerformHarvestsJob] [24376609-2164-4022-a996-a777e5c3ae9f] undefined method `gsub' for nil:NilClass
E, [2024-03-07T15:53:44.431591 #6] ERROR -- : [ActiveJob] [Spotlight::Resources::PerformHarvestsJob] [24376609-2164-4022-a996-a777e5c3ae9f] ["/usr/local/bundle/bundler/gems/spotlight-oaipmh-resources-4ab108799c8e/app/models/spotlight/resources/oaipmh_mods_parser.rb:69:in `search_id'", "/usr/local/bundle/bundler/gems/spotlight-oaipmh-resources-4ab108799c8e/app/models/spotlight/oaipmh_harvester.rb:54:in `harvest_item'", "/usr/local/bundle/bundler/gems/spotlight-oaipmh-resources-4ab108799c8e/app/models/spotlight/oaipmh_harvester.rb:25:in `block in harvest_items'", "/usr/local/bundle/gems/oai-1.2.1/lib/oai/client/list_records.rb:18:in `block in each'", "/usr/local/bundle/gems/oai-1.2.1/lib/oai/client/list_records.rb:17:in `each'", "/usr/local/bundle/gems/oai-1.2.1/lib/oai/client/list_records.rb:17:in `each'",
...
```

Examining the XML from the DRUM web interface
<https://api.drum.lib.umd.edu/server/oai/request?verb=ListRecords&metadataPrefix=mods&set=com_1903_2223>
it seems possible that the issue is that DRUM is not returning a MODS v3 record
with the "RecordInfo"/"RecordIdentifier" stanzas expected by the OAI-PMH MODS
parser.

Other attempts using the following Harvard OAI-PMH endpoint were also
unsuccessful:

* Base URL: `https://api.lib.harvard.edu/oai/`
* Set Spec: `scores`

## spotlight-oaipmh-resources Gem Installation

The following steps (modified from the steps in the "spotlight-oaipmh-resource"
[README.md](https://github.com/harvard-lts/spotlight-oaipmh-resources/blob/v3.0.4/README.md)
file) were used to install the gem:

1. Added the following lines to the “Gemfile”:

    ```text
    gem 'spotlight-oaipmh-resources', git: 'https://github.com/harvard-lts/spotlight-oaipmh-resources', tag: 'v3.0.4'
    gem 'delayed_job_active_record'
    gem 'rexml'
    ```

    * spotlight-oaipmh-resources - Needed to retrieve from GitHub, because
      3.0.4 version is not available from the RubyGems repository.
    * Did not add the "daemons" gem, because we are using Sidekiq to manage
      the delayed jobs.
    * Added the "rexml" gem as a direct dependency, because it is needed by
      "spotlight-oaipmh-resources". Ruby 3 no longer includes the "rexml" gem
      as a default gem. In local development, the "rexml" gem is added as
      an indirect dependency via the "selenium-webdriver" gem used for testing,
      but in production the "test" and "development" gems are not included,
      so it needs to be included explicitly.

2. Ran bundler:

    ```zsh
    $ bundle
    ```

3. Ran the generator:

    ```zsh
    $ rails generate spotlight:oaipmh:resources:install
    ```

4. Did not need to create a “tmp/pids” directory, because it already existed.

5. Ran database migrations:

    ```zsh
    $ SKIP_TRANSLATION=1 rails db:migrate
    ```

6. Did not need to add a `config.active_job.queue_adapter`, because the
   application was already configured to use SideKiq.
