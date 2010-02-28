class AudioEncoding < ActiveRecord::Base
  SERVER_URL = 'http://partyplay.heroku.com/mp3s/new.json'
  
  def self.find_audio_to_encode
    
  end
  
  def self.encode_audio_at_url(server_audio_id, original_url)
  end

end
