module CurationConcerns::ParentContainer
  extend ActiveSupport::Concern

  included do
    helper_method :parent
    # before_filter :authorize_edit_parent_rights!, except: [:show]  # Not sure we actually want this enforced any more (was originally in worthwhile), especially since GenericFiles and GenericWorks (which are PCDM::Objects)can belong to multiple parents
  end

  # TODO: this is slow, refactor to return a Presenter (fetch from solr)
  def parent
    @parent ||= new_or_create? ? find_parent_by_id : lookup_parent_from_child
  end

  def find_parent_by_id
    ActiveFedora::Base.find(parent_id)
  end

  def lookup_parent_from_child
    if curation_concern
      # in_objects method is inherited from Hydra::PCDM::ObjectBehavior
      curation_concern.in_objects.first
    elsif @presenter

      CurationConcerns::ParentService.parent_for(@presenter.id)
    else
      raise "no child"
    end
  end

  def parent_id
    @parent_id ||= new_or_create? ? params[:parent_id] : curation_concern.generic_works.in_objects.first.id
  end

  protected

    def new_or_create?
      %w(create new).include? action_name
    end

    def namespaced_parent_id
      # Sufia::Noid.namespaceize(params[:parent_id])
    end

    # restricts edit access so that you can only edit a record if you can also edit its parent.

    def authorize_edit_parent_rights!
      authorize! :edit, parent_id
    end
end
