class Attachment < ApplicationRecord
  include Activeable
  belongs_to :attachment_entity, polymorphic: true
  #attr_accessor :attachment_file,:file_name,:content_type

  mount_uploader :path,  AttachmentUploader
  before_create :set_fields

  def set_fields
    self.content_type = path.content_type
	  self.file_size = path.size
	  self.name = path.get_original_filename
  end

  def delete_company_attachment_it
	  self.destroy
	  return true
  end

  def attachment_path
    path.url
  end

end
