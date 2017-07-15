class Page < ApplicationRecord
  include AttachedToDataset
  validates :link, presence: true
end
