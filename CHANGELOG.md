# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

# [1.2.0] - 2016-11-15

### Added
* You can now specify the `colour` of a column: all projects within that column will be coloured appropriately, regardless of what group they're in.

### Changed
* Projects with nil names are now represented as empty strings when using `ProjectWrapper#to_s`.
* Updated README to reflect `colour` property.

# [1.1.2] - 2016-10-10
 
### Changed
* HISTORY is now CHANGELOG. Formatting based on Keep a Changelog.
* Edited README so examples on colouring groups are better.
* Non-group rendering in `column.erb` is slightly prettier.

### Fixed
* Default config docs now work properly without giving you errors.
* Will no longer try to load non-html files in the columns directory.
* Updated dependency version for RubyFocus.

## [1.1.1] - 2016-09-09

### Added
* `Omniboard::Column.reset_columns` allows you to wipe the global register of columns. Useful for unit testing.
* `Omniboard::Column.reset_config` now takes the option `:all` to wipe all configuration fields.

### Fixed
* The `config.rb` template file will now let you have projects that are not contained within folders.

## [1.1.0] - 2016-08-29

### Added
* You can now add custom CSS to your board. Any CSS in the file `custom.css` (inside your config file) will be included in the output HTML file. See the readme for more information.

## [1.0.1] - 2016-08-01

### Fixed
* Fixing CDATA tags within javascript - allows me to parse as XHTML while keeping JS all good.
* Improved display of column header numbers.

## [1.0.0] - 2016-07-08

### Added
* `Omniboard::document=` is available if you just want to set Omniboard's document variable by yourself without all that hassle of loading from file.
* If your document has no fetcher, it's always considered to be at head.
* Substantial changes to how groups work. You may now return any object from a `group_by` method, and use that object to sort your groups before displaying names. See the Readme for more information on how to use the updated groups.
* You can now custom colour your groups! See the Readme for more information.
* The column's `icon` methods may now return an array of `[icon, alt]`, for supplying popup information on icons.
* You can add a "refresh" link to the top of the page using the `refresh_link` property inside `config`.
* Setting `hide_dimmed` on a column will automatically hide dimmed projects on page load
* Set project counts using the `display_project_counts` property on columns. Can be set to `all`, `active`, or `marked`.

## [0.4.0] - 2016-06-27

### Added
* Added some shiny CSS for the project details - notes and remaining tasks lists should be a bit sexier


### Changed
* Project notes will now show basic styling (italics, bold, underline; better paragraphs).
* Projects now show due and deferral dates (when appropriate) in the project overlay

## [0.3.3] - 2016-05-23

### Added
* Omniboard works out when your document is out of date, or even when it's become detached from the head of your omnifocus database, and lets you know.

### Fixed
* `Group` now has a default `light_colour` method - no more errors if you don't group your projects!


## [0.3.1] - 2016-02-13

### Fixed
* Remove console.log() debugging in js functions
* Previous change to hide/show code resulted in a non-functioning info overlay. Now fixed.

## [0.3.0] - 2016-02-12

### Added
* You can now set a block property to `nil` to avoid running any block (including any defaults).

## [0.2.1] - 2016-02-09

### Fixed
* Added `trollop` to list of runtime dependencies

## [0.2.0] - 2016-02-08

### Changed
* Project groups will hide themselves if every child project has been hidden.

### Added
* Added `Column#filter_button`, which allows you to add a button filtering out dimmed tasks.

## [0.1.0] - 2016-02-04

Hello, world!