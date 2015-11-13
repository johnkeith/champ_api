require "spec_helper"

RSpec.describe Api::V1::FitbitAuthController do
  def app
    Api::V1::FitbitAuthController # this defines the active application for this test
  end

  it "is running in test env" do
  	expect(Sinatra::Base.environment).to eq(:test)
  end

  it "returns successfully" do
    get "/"

    expect(last_response.status).to eq 200
  end
end