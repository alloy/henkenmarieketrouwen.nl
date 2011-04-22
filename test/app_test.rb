require File.expand_path('../test_helper', __FILE__)

class InviteeTest < Test::Unit::TestCase
  def setup
    invitation = Invitation.create(:id => 123, :attendees => 'Bassie, Adriaan')
    p invitation
  end

  def teardown
    Invitation.delete_all
  end

  it "sees an invitation page" do
    get '/123'
    assert last_response.ok?
    assert_have_tag 'form[@action="/invitations"][@method=post]' do
      assert_have_tag 'input[@name="attendees"][@value="Bassie, Adriaan"]'
    end
  end

  it "confirms who will be attending and whether or not they will attend the wedding itself" do
    post '/invitations/123', :invitation => { :attending_wedding => '1', :attendees => 'Bassie, Adriaan' }
    assert last_response.redirect?
    assert_equal 'http://example.org/invitations/123', last_response.headers['Location']
    invitation = Invitation.find(123)
    assert invitation.attending_wedding?
    assert_equal %w{ Bassie Adriaan }, invitation.attendees
  end
end

