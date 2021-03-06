module CurationConcerns
  class WorkIndexingService < ActiveFedora::IndexingService
    include IndexesThumbnails
    def generate_solr_document
      super.tap do |solr_doc|
        # We know that all the members of GenericWorks are GenericFiles so we can use
        # member_ids which requires fewer Fedora API calls than file_set_ids.
        # file_set_ids requires loading all the members from Fedora but member_ids
        # looks just at solr
        solr_doc[Solrizer.solr_name('member_ids', :symbol)] = object.member_ids
        Solrizer.set_field(solr_doc, 'generic_type', 'Work', :facetable)
        solr_doc['thumbnail_path_ss'] = thumbnail_path
      end
    end
  end
end
