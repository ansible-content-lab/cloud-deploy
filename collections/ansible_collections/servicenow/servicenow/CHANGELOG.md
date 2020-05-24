# ServiceNow Collection Changes

## [1.0.2]
### Added
  - CHANGELOG

### Fixed
  - Fix Syntax for missing commits after Ansible Collection Migration
  - Fix bugs from sanity testing

## [1.0.1]

### Added
  - Enhanced Inventory Support `plugins/inventory/now.py`
    - Included update Set for ServiceNow scripted REST API to return CI relationships
    - Added `enhanced` option in plugin to enable using scripted REST API endpoint
    - Added `enhanced_groups` option to plugin to create groups from CI relationships
  - README with description of requirements, usage, and installation

### Fixed
  - Updated namespace for collection in `plugins/inventory/now.py`
  - Updated path to imports in modules `snow_record` and `snow_record_find`
  

## [1.0.0]
### Added
  - Initial migration of ServiceNow content from Ansible core (2.9 / devel)
    - ** Modules **
      - `snow_record`
      - `snow_record_find`

  - New Content:
    - ** Inventory Sources **
      - `now`