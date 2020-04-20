# frozen_string_literal: true

class Artifact < ApplicationRecord
  attr_accessor :upload
  belongs_to :project

  MAX_FILESIZE = 10.megabytes
  validates_presence_of :name, :upload
  validates_uniqueness_of :name

  validate :uploaded_file_size

  private

  def uploaded_file_size
    return unless upload

    return if upload.size <= self.class::MAX_FILESIZE

    errors.add(:upload, "File must be less than #{self.class::MAX_FILESIZE}")
  end
end
