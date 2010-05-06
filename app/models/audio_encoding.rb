require 'open-uri'
require 'rest_client'
require 'RMagick'

class AudioEncoding < ActiveRecord::Base
  SERVER_URL = 'http://partyplay.heroku.com/encodings/new.json'
  ENCODING_UPLOAD_URL = 'http://partyplay.heroku.com/encodings'
  DOWNLOAD_PATH = "#{RAILS_ROOT}/public/images/downloads"
  CREDS = '9f0083af27bff83ce5d4841716f5ec2f'
  MILLISECONDS_PER_FRAME = 33
  FRAMES_PER_SECOND = 30

  validates_uniqueness_of :server_audio_id

  def self.find_audio_to_encode
    @uploads = ActiveSupport::JSON.decode(open(SERVER_URL).read)

    # Find the first audio requiring encoding that's not already in the database
    @uploads.each do |upload|
      server_audio_id = upload['upload']['id']
      ae = AudioEncoding.find_by_server_audio_id(server_audio_id)
      unless ae
        return AudioEncoding.create!(:server_audio_id => server_audio_id, :original_url => upload['upload']['original_attachment_url'].split('?').first, :picture_coordinates => upload['upload']['picture_coordinates'])
      end
    end
    nil
  end

  def encode_mp3_and_video
    # Download original audio and write started_download
    update_attribute(:started_download, Time.now)
    working_dir = "#{DOWNLOAD_PATH}/#{self.id}"
    working_video_dir = "#{working_dir}/video"
    FileUtils.mkdir(working_dir)
    original_file = original_url.split('/').last.split('?').first
    `wget --directory-prefix=#{working_dir} #{self.original_url} `

    mp3_file = "#{working_dir}/#{original_file}.mp3"
    avi_file = nil


    # Encode audio download and write started_encoding
    update_attribute(:started_encoding, Time.now)
    `sndfile-convert #{working_dir}/#{original_file} #{working_dir}/#{original_file}.aiff`
    `sox #{working_dir}/#{original_file}.aiff #{mp3_file}`


    # If there is any video file, encode that too
    unless picture_coordinates.blank?
      # set started_drawing and output frames
      update_attribute(:started_drawing, Time.now)
      count = ouput_video_frames(ActiveSupport::JSON.decode(picture_coordinates), working_video_dir)
      logger.debug "Gathered #{count} frames for video #{id}"

      # set started_assembling_video, and merge all image frame files into a video
      update_attribute(:started_assembling_video, Time.now)
      `ffmpeg -qscale 2 -r #{FRAMES_PER_SECOND} -b 9600 -i #{working_video_dir}/%08d.png -i #{mp3_file} #{working_dir}/#{original_file}.avi`
      avi_file = "#{working_dir}/#{original_file}.avi"

      # Remove working files
      FileUtils.rm Dir.glob("#{working_video_dir}/*.png")

      # set completed_video_at
      update_attribute(:completed_video_at, Time.now)
    end

    # Upload back to server and write started_upload
    update_attribute(:started_upload, Time.now)
    if avi_file
      RestClient.post ENCODING_UPLOAD_URL, :upload_id => server_audio_id, :upload => { :avi => File.new(avi_file) }, :credentials => { :key => CREDS }
    else
      RestClient.post ENCODING_UPLOAD_URL, :upload_id => server_audio_id, :upload => { :mp3 => File.new(mp3_file)}, :credentials => { :key => CREDS }
    end

    # Write completed_at
    update_attribute(:completed_at, Time.now)

    # Remove files
    FileUtils.rm Dir.glob("#{working_dir}/*.caf")
    FileUtils.rm Dir.glob("#{working_dir}/*.caf.*")
    # FileUtils.rm(["#{working_dir}/#{original_file}", "#{working_dir}/#{original_file}.aiff", mp3_file])
    # FileUtils.rm([avi_file]) if avi_file

    return true
  end

  # Returns number of frames
  # Example coords array: [ [[71,66,378],[72,66,396]] , [[72,66,397],[76,70,412]] , ... ]
  def ouput_video_frames(coords_array, working_dir)
    FileUtils.mkdir(working_dir)
    canvas = Magick::Image.new(1024, 768) do
      self.background_color = 'white'
    end
    # draw = Magick::Draw.new ## Don't just use a single draw object, because it slows things down.

    frame = 0
    draw = Magick::Draw.new
    draw.stroke_width(3)
    draw.fill_opacity(0)
    (0...coords_array.size).each do |i|
      tuple = coords_array[i]
      start_point = tuple[0]
      end_point = tuple[1]

      if start_point[0] == 'clear'
        # Open up a new blank canvas for the clear command
        canvas = Magick::Image.new(1024, 768) do
          self.background_color = 'white'
        end 
        # Try to prevent odd gray lines over background
        draw = Magick::Draw.new
        draw.stroke_width(3)
        draw.fill_opacity(0)
        draw.stroke('white')
        draw.fill('white')
        draw.circle(0, 0, 3, 3)
        draw.draw(canvas)
      else
        # draw.circle(coords[0].to_i, coords[1].to_i, coords[0].to_i, coords[1].to_i + 3)
      end
      
      # if we need to output more frames to get to the first timestamp, just output that many frames
      until start_point[2] <= frame * MILLISECONDS_PER_FRAME
        frame = frame + 1
        filenum = "%08d" % frame
        canvas.write("#{working_dir}/#{filenum}.png")
        
        draw = Magick::Draw.new
        draw.stroke_width(3)
        draw.fill_opacity(0)
        draw.stroke('blue')
        draw.fill('blue')
      end
      
      # [[71,66,378],[72,66,396]] , [[72,66,397],[76,70,412]] , ... ]
      
      # 3 possibilities:
      last_drawn_point = start_point
      
      #   end_point timestamp > 1 frame
      
      while end_point[2] > ((frame+1) * MILLISECONDS_PER_FRAME)
        # How far do we go in 1 frame?  A percentage of the total distance we're supposed to go in the remaing frames
        percentage = 1.00000 / ((1.0000 * end_point[2] - frame * MILLISECONDS_PER_FRAME) / MILLISECONDS_PER_FRAME)
        
        # calculate the percentage between the previous frame and the future frame, and draw the line between that
        next_point = [ 
          (1.00000 * last_drawn_point[0] + ((end_point[0] - start_point[0]) * percentage)).round, 
          (1.00000 * last_drawn_point[1] + ((end_point[1] - start_point[1]) * percentage)).round 
        ]
        
        if start_point[0] != 'clear'
          draw.line(last_drawn_point[0], last_drawn_point[1], next_point[0], next_point[1])
        end
        frame = frame + 1
        filenum = "%08d" % frame
        canvas.write("#{working_dir}/#{filenum}.png")
        last_drawn_point = next_point
        
        draw = Magick::Draw.new
        draw.stroke_width(3)
        draw.fill_opacity(0)
        draw.stroke('blue')
        draw.fill('blue')
      end
        
        
      #   end_point timestamp == 1 frame
      if end_point[2] == ((frame+1) * MILLISECONDS_PER_FRAME)
        if start_point[0] != 'clear'
          draw.line(last_drawn_point[0], last_drawn_point[1], end_point[0], end_point[1])
        end
        frame = frame + 1
        filenum = "%08d" % frame
        canvas.write("#{working_dir}/#{filenum}.png")
        draw = Magick::Draw.new
        draw.stroke_width(3)
        draw.fill_opacity(0)

      #   end_point timestamp < 1 frame
      else # end_point[2] < ((frame+1) * MILLISECONDS_PER_FRAME)
        if start_point[0] != 'clear'
          draw.line(last_drawn_point[0], last_drawn_point[1], end_point[0], end_point[1])
        end
      end
      
      
      # Calculate how many frames this point represents, and output each frame, must cast to float to get correct rounding
      # frames = i + 1 == coords_array.size ? 1 : (1.0000 * (coords_array[i+1][2] - coords[2]) / MILLISECONDS_PER_FRAME).round # last frame vs. not last frame
      # 
      # (0...frames).each do |f|
      #   frame = frame + 1
      #   filenum = "%08d" % frame
      #   canvas.write("#{working_dir}/#{filenum}.png")
      # end
    end

    return frame
  end

end
