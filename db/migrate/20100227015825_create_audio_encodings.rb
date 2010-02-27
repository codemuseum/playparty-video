class CreateAudioEncodings < ActiveRecord::Migration
  def self.up
    create_table :audio_encodings do |t|
      t.integer :server_audio_id
      t.string :original_url
      t.boolean :error_downloading
      t.text :error_downloading_message
      t.boolean :error_encoding
      t.text :error_encoding_message
      t.boolean :error_uploading
      t.text :error_uploading_message
      t.datetime :started_download
      t.datetime :started_encoding
      t.datetime :started_upload
      t.datetime :completed_at

      t.timestamps
    end
    add_index :audio_encodings, :server_audio_id
    add_index :audio_encodings, :original_url
    add_index :audio_encodings, :error_downloading
    add_index :audio_encodings, :error_encoding
    add_index :audio_encodings, :error_uploading

  end

  def self.down
    drop_table :audio_encodings
  end
end
