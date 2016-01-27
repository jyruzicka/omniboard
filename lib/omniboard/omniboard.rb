module Omniboard
	@configuration = {}

	class << self
		# Retrieve a configuration variable
		def configuration(key)
			@configuration[key]
		end

		# Set configuration variables from a dictionary
		def configuration=(hsh)
			@configuration = @configuration.merge(hsh)
		end

		# Set individual configuration variable
		def configure(key,val)
			@configuration[key] = val
		end

		#---------------------------------------
		# Config location methods

		# Set location where we'll store the configuration files
		def config_location= loc
			self.configure(:config_location, loc)
		end

		# Retrieve configuration_location
		def config_location
			@configuration[:config_location] || default_config_location
		end

		# Database usually exists here
		def default_config_location
			@default_config_location ||= File.join(ENV["HOME"], ".omniboard")
		end

		# Does the config folder exist?
		def config_exists?
			File.exists?(config_location)
		end

		# Populate with base classes
		def populate

			# 1. Make the columns folder
			FileUtils::mkdir_p columns_location

			# 2. Drop base columns + config into columns folder
			Dir[File.join(__dir__, "columns/*.rb")].each{ |f| FileUtils::cp f, columns_location }
		end

		#---------------------------------------
		# Column-centric methods

		# This is where we store columns
		def columns_location
			File.join(config_location, "columns")
		end

		# Fetch all columns!
		def columns
			@columns ||= begin
				Dir[File.join(columns_location, "*")].each{ |f| require(f) } if File.exists?(columns_location)
				Omniboard::Column.columns
			end
		end

		#---------------------------------------
		# Project-centric methods

		def projects
			@document.projects
		end

		#---------------------------------------
		# Document-centric methods

		# This is where our serialised document is located
		def document_location
			File.join(config_location, "db.yaml")
		end

		# Do we already have a serialised document?
		def document_exists?
			File.exists?(document_location)
		end

		# Load document from file
		def load_document
			@document = YAML::load_file(document_location)
		end

		# Save document to file
		def save_document
			FileUtils::mkdir_p config_location unless File.exists?(config_location)
			File.open(document_location, "w"){ |io| io.puts YAML.dump(@document) }
		end

		# Update from an existing rubyfocus document
		def update_document
			@document.update
		end

		# Create a new document. For now, local documents are the only sort supported
		def create_document
			@document = Rubyfocus::Document.new(Rubyfocus::LocalFetcher.new)
		end
	end
end