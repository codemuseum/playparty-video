class AudioEncodingsController < ApplicationController
  # GET /audio_encodings
  # GET /audio_encodings.xml
  def index
    @audio_encodings = AudioEncoding.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @audio_encodings }
    end
  end

  # GET /audio_encodings/1
  # GET /audio_encodings/1.xml
  def show
    @audio_encoding = AudioEncoding.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @audio_encoding }
    end
  end

  # GET /audio_encodings/new
  # GET /audio_encodings/new.xml
  def new
    @audio_encoding = AudioEncoding.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @audio_encoding }
    end
  end

  # GET /audio_encodings/1/edit
  def edit
    @audio_encoding = AudioEncoding.find(params[:id])
  end

  # POST /audio_encodings
  # POST /audio_encodings.xml
  def create
    @audio_encoding = AudioEncoding.new(params[:audio_encoding])

    respond_to do |format|
      if @audio_encoding.save
        flash[:notice] = 'AudioEncoding was successfully created.'
        format.html { redirect_to(@audio_encoding) }
        format.xml  { render :xml => @audio_encoding, :status => :created, :location => @audio_encoding }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @audio_encoding.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /audio_encodings/1
  # PUT /audio_encodings/1.xml
  def update
    @audio_encoding = AudioEncoding.find(params[:id])

    respond_to do |format|
      if @audio_encoding.update_attributes(params[:audio_encoding])
        flash[:notice] = 'AudioEncoding was successfully updated.'
        format.html { redirect_to(@audio_encoding) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @audio_encoding.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /audio_encodings/1
  # DELETE /audio_encodings/1.xml
  def destroy
    @audio_encoding = AudioEncoding.find(params[:id])
    @audio_encoding.destroy

    respond_to do |format|
      format.html { redirect_to(audio_encodings_url) }
      format.xml  { head :ok }
    end
  end
end
