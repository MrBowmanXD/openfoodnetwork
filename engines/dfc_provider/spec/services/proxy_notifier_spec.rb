# frozen_string_literal: true

require_relative "../spec_helper"

# These tests depend on valid OpenID Connect client credentials in your
# `.env.test.local` file.
#
#     OPENID_APP_ID="..."
#     OPENID_APP_SECRET="..."
RSpec.describe ProxyNotifier do
  let(:platform_url) { "https://api.proxy-dev.cqcm.startinblox.com/profile" }

  it "receives an access token", :vcr do
    token = subject.request_token(platform_url)
    expect(token).to be_a String
    expect(token.length).to be > 20
  end

  it "notifies the proxy", :vcr do
    # The test server is not reachable by the notified server.
    # If you don't have valid credentials, you'll get an unauthorized error.
    # Correctly authenticated, the server fails to update its data.
    expect {
      subject.refresh(platform_url)
    }.to raise_error Faraday::ServerError
  end
end
