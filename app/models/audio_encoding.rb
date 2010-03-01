require 'open-uri'
require 'rest_client'

class AudioEncoding < ActiveRecord::Base
  SERVER_URL = 'http://partyplay.heroku.com/mp3s/new.json'
  MP3_UPLOAD_URL = 'http://partyplay.heroku.com/mp3s'
  DOWNLOAD_PATH = "#{RAILS_ROOT}/public/images/downloads"
  
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
    update_attribute(:started_download, Time.now)
    working_dir = "#{DOWNLOAD_PATH}/#{self.id}"
    FileUtils.mkdir(working_dir)
    original_file = `wget --directory-prefix=#{working_dir} #{self.original_url} `
  
    # Encode download and write started_encoding
    update_attribute(:started_encoding, Time.now)
    aiff_file = `sndfile-convert #{working_dir}/#{original_file} #{working_dir}/#{original_file}.aiff`
    mp3_file = `sox #{working_dir}/#{original_file}.aiff #{working_dir}/#{original_file}.mp3`
    
    # Upload back to server and write started_upload
    update_attribute(:started_upload, Time.now)
    RestClient.post MP3_UPLOAD_URL, :upload => { :id => server_audio_id, :mp3 => File.new("#{working_dir}/#{original_file}.mp3")}
    
    # Write completed_at
    
    # Remove files
    
    return true
  end

end
