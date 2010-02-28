require 'open-uri'

class AudioEncoding < ActiveRecord::Base
  SERVER_URL = 'http://partyplay.heroku.com/mp3s/new.json'
  
  validates_uniqueness_of :server_audio_id
  
  def self.find_audio_to_encode
    @uploads = ActiveSupport::JSON.decode(open(SERVER_URL).read)
    
    # Find the first audio requiring encoding that's not already in the database
    @uploads.each do |upload|
      server_audio_id = upload['upload']['id']
      ae = AudioEncoding.find_by_id(server_audio_id)
      unless ae
        return AudioEncoding.create!(:server_audio_id => server_audio_id, :original_url => upload['upload']['original_attachment_url'])
      end
    end
    nil
  end
  
  def encode_to_mp3
    # Download original and write started_download
    
    # Encode download and write started_encoding
    
    # Upload back to server and write started_upload
    
    # Write completed_at
    
    return true
  end

end
