module AttachedToDataset
  extend ActiveSupport::Concern
  
  included do
    before_save :set_dataset_id, unless: :dataset_id?
  end

  private 
    def set_dataset_id
      self.dataset_id = (self.class.maximum(:dataset_id) || 0) + 1
    end
end