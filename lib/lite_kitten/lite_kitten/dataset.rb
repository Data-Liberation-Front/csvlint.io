require_relative 'origins'
require 'data_kitten/hosts'
require 'data_kitten/publishing_formats'

module DataKitten

  # Represents a single dataset from some origin (see {http://www.w3.org/TR/vocab-dcat/#class-dataset dcat:Dataset}
  # for relevant vocabulary).
  #
  # Designed to be created with a URI to the dataset, and then to work out metadata from there.
  #
  # Currently supports Datasets hosted in Git (and optionally on GitHub), and which
  # use the Datapackage metadata format.
  #
  # @example Load a Dataset from a git repository
  #   dataset = Dataset.new(access_url: 'git://github.com/theodi/dataset-metadata-survey.git')
  #   dataset.supported?         # => true
  #   dataset.origin             # => :git
  #   dataset.host               # => :github
  #   dataset.publishing_format  # => :datapackage
  #
  class Dataset

    include DataKitten::Origins
    include DataKitten::Hosts
    include DataKitten::PublishingFormats

    # @!attribute access_url
    #   @return [String] the URL that gives access to the dataset
    attr_accessor :access_url
    alias_method :uri, :access_url
    alias_method :url, :access_url

    # Create a new Dataset object
    #
    # @param [Hash] options the details of the Dataset.
    # @option options [String] :access_url A URL that can be used to access the Dataset.
    #                                      The class will attempt to auto-load metadata from this URL.
    #
    def initialize(options)
      @access_url = options[:access_url]
      detect_origin
      detect_host
      detect_publishing_format
    end

    # Can metadata be loaded for this Dataset?
    #
    # @return [Boolean] true if metadata can be loaded, false if it's
    #                   an unknown origin type, or has an unknown metadata format.
    def supported?
      !(origin.nil? || publishing_format.nil?)
    end

    # The origin type of the dataset.
    #
    # @return [Symbol] The origin type. For instance, datasets loaded from git
    #                  repositories will return +:git+. If no origin type is
    #                  identified, will return +nil+.
    def origin
      nil
    end

    # Where the dataset is hosted.
    #
    # @return [Symbol] The host. For instance, data loaded from github repositories
    #                  will return +:github+. This can be used to control extra host-specific
    #                  behaviour if required. If no host type is identified, will return +nil+.
    def host
      nil
    end

    # The human-readable title of the dataset.
    #
    # @return [String] the title of the dataset.
    def data_title
      nil
    end

    # A brief description of the dataset
    #
    # @return [String] the description of the dataset.
    def description
      nil
    end

    # Keywords for the dataset
    #
    # @return [Array<string>] an array of keywords
    def keywords
      []
    end

    # Human-readable documentation for the dataset.
    #
    # @return [String] the URL of the documentation.
    def documentation_url
      nil
    end

    # What type of dataset is this?
    # Options are: +:web_service+ for API-accessible data, or +:one_off+ for downloadable data dumps.
    #
    # @return [Symbol] the release type.
    def release_type
      false
    end

    # Date the dataset was released
    #
    # @return [Date] the release date of the dataset
    def issued
      nil
    end
    alias_method :release_date, :issued

    # Date the dataset was last modified
    #
    # @return [Date] the dataset's last modified date
    def modified
      nil
    end

    # The temporal coverage of the dataset
    #
    # @return [Object<Temporal>] the start and end dates of the dataset's temporal coverage
    def temporal
      nil
    end

    # Where the data is sourced from
    #
    # @return [Array<Source>] the sources of the data, each as a Source object.
    def sources
      []
    end

    # Is the information time-sensitive?
    #
    # @return [Boolean] whether the information will go out of date.
    def time_sensitive?
      false
    end

    # The publishing format for the dataset.
    #
    # @return [Symbol] The format. For instance, datasets that publish metadata in
    #                  Datapackage format will return +:datapackage+. If no format
    #                  is identified, will return +nil+.
    def publishing_format
      nil
    end

    # A list of maintainers
    #
    # @return [Array<Agent>] An array of maintainers, each as an Agent object.
    def maintainers
      []
    end

    # A list of publishers
    #
    # @return [Array<Agent>] An array of publishers, each as an Agent object.
    def publishers
      []
    end

    # A list of licenses
    #
    # @return [Array<License>] An array of licenses, each as a License object.
    def licenses
      []
    end

    # The rights statment for the data
    #
    # @return [Object<Rights>] How the content and data can be used, as well as copyright notice and attribution URL
    def rights
      nil
    end

    # A list of contributors
    #
    # @return [Array<Agent>] An array of contributors to the dataset, each as an Agent object.
    def contributors
      []
    end

    # Has the data been crowdsourced?
    #
    # @return [Boolean] Whether the data has been crowdsourced or not.
    def crowdsourced?
      false
    end

    # The URL of the contributor license agreement
    #
    # @return [String] A URL for the agreement that contributors accept.
    def contributor_agreement_url
      nil
    end

    # A list of distributions. Has aliases for popular alternative vocabularies.
    #
    # @return [Array<Distribution>] An array of Distribution objects.
    def distributions
      []
    end
    alias_method :files, :distributions
    alias_method :resources, :distributions

    # How frequently the data is updated.
    #
    # @return [String] The frequency of update expressed as a dct:Frequency.
    def update_frequency
      nil
    end

    # A history of changes to the Dataset
    #
    # @return [Array] An array of changes. Exact format depends on the origin and publishing format.
    def change_history
      []
    end

  end
end
