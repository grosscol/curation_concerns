
module CurationConcerns
  class GenericWorkActor < CurationConcerns::BaseActor
    include CurationConcerns::ManagesEmbargoesActor

    def create
      # set the @files ivar then remove the files attribute so it isn't set by default.
      files && attributes.delete(:files)
      assign_pid && interpret_visibility && super && attach_files && assign_representative && copy_visibility
    end

    def update
      add_to_collections(attributes.delete(:collection_ids)) &&
          interpret_visibility && super && attach_files && copy_visibility
    end

    delegate :visibility_changed?, to: :curation_concern

    protected

    # Is this here to ensure that the curation_concern has a pid set before any of the other methods are executed?
    def assign_pid
      curation_concern.send(:assign_id)
    end

    def files
      return @files if defined?(@files)
      @files = [attributes[:files]].flatten.compact
    end

    def attach_files
      files.all? do |file|
        attach_file(file)
      end
    end

    # The default behavior of active_fedora's aggregates association,
    # when assigning the id accessor (e.g. collection_ids = ['foo:1']) is to add
    # to new collections, but not remove from old collections.
    # This method ensures it's removed from the old collections.
    def add_to_collections(new_collection_ids)
      return true unless new_collection_ids
      #remove from old collections
      (curation_concern.collection_ids - new_collection_ids).each do |old_id|
        Collection.find(old_id).members.delete(curation_concern)
      end

      #add to new
      new_collection_ids.each do |coll_id|
        collection = Collection.find(coll_id)
        collection.members << curation_concern
        collection.save
      end
      true
    end

    def assign_representative
      @generic_files ||= []
      unless curation_concern.representative
        curation_concern.representative = @generic_files.first.id unless @generic_files.empty?
      end
      curation_concern.save
    end

    private

    # @param [#read, #content_type, #original_filename] file is expected to be a readable object with original name and mimetype metadata.
    def attach_file(file)
      generic_file = ::GenericFile.new
      generic_file_actor = CurationConcerns::GenericFileActor.new(generic_file, user)
      generic_file_actor.create_metadata(curation_concern.id, curation_concern.id)
      generic_file.visibility = visibility
      generic_file_actor.create_content(file)
      @generic_files ||= []
      @generic_files << generic_file # This is so that other methods like assign_representative can access the generic_files wihtout reloading them from fedora
      Hydra::Works::AddGenericFileToGenericWork.call(curation_concern, generic_file)
    end

    def valid_file?(file_path)
      return file_path.present? && File.exists?(file_path) && !File.zero?(file_path)
    end

    # The path of the fedora node where we store the file data
    def file_path
      'content'
    end
  end
end
