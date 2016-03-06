class RandomFiretalksController < ApplicationController

  require 'opentok'
  require 'json'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  before_filter :config_opentok, :except => [:index, :destroy]

  before_filter :grab_new_topic

  def join
    # get all public firetalks who are not in progress with current topic
    # if no firetalks, make a new one
    @user = User.find(session[:user_id])
    @firetalks = Firetalk.where(:public => true, :in_progress => false, :topic => @topic, :full => false)
    if @firetalks.any?
      # join random one
      @firetalk = @firetalks.sample
      if !FiretalkDebater.where(:user_id => @user.id, :firetalk_id => @firetalk.id).any?
        @firetalk.firetalk_debaters.build(:email => @user.email, :user_id => @user.id, :firetalk_id => @firetalk.id)
      end
      if @firetalk.save!
        redirect_to user_firetalk_path(:id => @firetalk.id, :user_id => @firetalk.user_id)
      end
    else
      # make new one
      @firetalk = Firetalk.new(:topic => @topic, :user_id => @user.id, :name => "Test Firetalk!", :public  => true)
      if @firetalk.save
        @firetalk.firetalk_debaters.create!(:email => @user.email, :user_id => @user.id, :firetalk_id => @firetalk.id)
        redirect_to user_firetalk_path(@user, @firetalk)
      end
    end

  end

  def watch
    # go to firetalk as spectator which is public and in progress
  end

  private
  def config_opentok
    if @opentok.nil?
      @opentok = OpenTok::OpenTok.new '45241592', 'b099560439c52ed195d79cb7c15fbae1d9b33f1e'
    end
  end
end
