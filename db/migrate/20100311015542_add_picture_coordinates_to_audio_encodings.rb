class AddPictureCoordinatesToAudioEncodings < ActiveRecord::Migration
  def self.up
    add_column :audio_encodings, :picture_coordinates, :text
    add_column :audio_encodings, :started_drawing, :datetime
    add_column :audio_encodings, :started_assembling_video, :datetime
    add_column :audio_encodings, :started_merging_audio_with_video, :datetime
    add_column :audio_encodings, :completed_video_at, :datetime
  end

  def self.down
    remove_column :audio_encodings, :picture_coordinates
    remove_column :audio_encodings, :started_drawing
    remove_column :audio_encodings, :started_assembling_video
    remove_column :audio_encodings, :started_merging_audio_with_video
    remove_column :audio_encodings, :completed_video_at
  end
end
