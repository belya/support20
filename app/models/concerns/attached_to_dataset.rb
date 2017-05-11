module AttachedToDataset
  extend ActiveSupport::Concern
  
  included do
    after_save :set_dataset_id, unless: :dataset_id?
  end

  private 
    def set_dataset_id
      self.dataset_id = id
    end
end