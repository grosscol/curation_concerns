module CurationConcerns
  module GenericFileBehavior
    extend ActiveSupport::Concern
    include Hydra::Works::GenericFileBehavior
    include Hydra::Works::GenericFile::Characterization
    include Hydra::Works::GenericFile::Characterization::Doc
    include Hydra::Works::GenericFile::Characterization::Image
    include Hydra::Works::GenericFile::Characterization::Video
    include Hydra::Works::GenericFile::Characterization::Audio
    include Hydra::Works::GenericFile::VirusCheck
    include Hydra::WithDepositor
    include CurationConcerns::Serializers
    include CurationConcerns::Noid
    include CurationConcerns::GenericFile::Derivatives
    include CurationConcerns::Permissions
    include CurationConcerns::BasicMetadata
    include CurationConcerns::GenericFile::Content
    include CurationConcerns::GenericFile::FullTextIndexing
    include CurationConcerns::GenericFile::Indexing
    include CurationConcerns::GenericFile::BelongsToWorks
    include CurationConcerns::GenericFile::BelongsToUploadSets
    include Hydra::AccessControls::Embargoable

    included do
      attr_accessor :file
    end

    def human_readable_type
      self.class.to_s.demodulize.titleize
    end

    def representative
      to_param
    end
  end
end
