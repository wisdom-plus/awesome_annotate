# Changelog

## [0.3.0] - 2026-05-31

- Added `awesome_annotate init` to create
  `config/initializers/awesome_annotate.yml`.
- Added configuration loading for annotation and remove commands.
- Added path configuration:
  - `env_file_path`
  - `model_dir`
  - `route_file_path`
- Added `annotation_position` to choose whether new annotation blocks are
  inserted at the top or bottom of files.
- Added model annotation filters and output controls:
  - `exclude_model_files`
  - `include_indexes`
  - `exclude_columns`
  - `include_column_defaults`
- Added `exclude_routes` to omit matching route lines from route annotations.
- Added validation for supported configuration value types.

## [0.2.0] - 2026-05-10

- Added model schema annotations with column type, nullability, primary key,
  default value, and basic index information.
- Added duplicate-safe annotation blocks with AwesomeAnnotate start and end
  markers.
- Added route annotations for `config/routes.rb`.
- Added model commands:
  - `awesome_annotate model MODEL`
  - `awesome_annotate models`
  - `awesome_annotate models MODEL...`
- Added `awesome_annotate all` to annotate all models and routes.
- Added remove commands:
  - `awesome_annotate remove model MODEL`
  - `awesome_annotate remove models`
  - `awesome_annotate remove routes`
  - `awesome_annotate remove all`
- Added Rails-like integration specs and GitHub Actions CI for RSpec and
  RuboCop.
- Documented supported Ruby and Active Record versions.

## [0.1.3] - 2024-05-05

- Add a new feature
  - annotate routes command

## [0.1.2] - 2024-05-03

- Add a new feature
  - --version flag

## [0.1.1] - 2024-05-02

- Fixed a bug

## [0.1.0] - 2024-04-29

- Initial release
