# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [4.1.0] - 2018-01-19
### Added
- `/fpm-status` status page on port 9001.
- The MaxMind Geolite Legacy database now ships with the container

### Changes
- Disabled the memory and execution time limits for PHP CLI mode
- PHP: 7.1.13
- nginx: 1.10.3

### Removed
- `VAR_HEAP_INDEX` environment variable (was never used in 4.x series)

## [4.0.0] - 2017-06-14
Initial open-source release.

- PHP: 7.1.6
- nginx: 1.10.0
- imagemagick: 6.8.9-9

