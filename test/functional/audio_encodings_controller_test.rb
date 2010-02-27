require 'test_helper'

class AudioEncodingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:audio_encodings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create audio_encoding" do
    assert_difference('AudioEncoding.count') do
      post :create, :audio_encoding => { }
    end

    assert_redirected_to audio_encoding_path(assigns(:audio_encoding))
  end

  test "should show audio_encoding" do
    get :show, :id => audio_encodings(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => audio_encodings(:one).to_param
    assert_response :success
  end

  test "should update audio_encoding" do
    put :update, :id => audio_encodings(:one).to_param, :audio_encoding => { }
    assert_redirected_to audio_encoding_path(assigns(:audio_encoding))
  end

  test "should destroy audio_encoding" do
    assert_difference('AudioEncoding.count', -1) do
      delete :destroy, :id => audio_encodings(:one).to_param
    end

    assert_redirected_to audio_encodings_path
  end
end
