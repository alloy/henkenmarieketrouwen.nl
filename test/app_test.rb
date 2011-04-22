require File.expand_path('../test_helper', __FILE__)

class InvitationTest < Test::Unit::TestCase
  def setup
    @invitation = Invitation.new(:attendees => 'Bassie, Adriaan')
  end

  def teardown
    Invitation.delete_all
  end

  it "cleans the whitespace between the names" do
    @invitation.attendees = "Bassie, "
    assert_equal 'Bassie', @invitation.attendees
    @invitation.attendees = "Bassie,Adriaan"
    assert_equal 'Bassie, Adriaan', @invitation.attendees
    @invitation.attendees = "  Bassie\t \t,Adriaan   "
    assert_equal 'Bassie, Adriaan', @invitation.attendees
  end

  it "returns a sentence for the list of attendees" do
    assert_equal 'Bassie en Adriaan', @invitation.attendees_sentence
    @invitation.attendees = 'Greet'
    assert_equal 'Greet', @invitation.attendees_sentence
    @invitation.attendees = 'Rini, Sander, Mats, Mila, Nena, Jacky, Yuka'
    assert_equal 'Rini, Sander, Mats, Mila, Nena, Jacky en Yuka', @invitation.attendees_sentence
  end
end

class InviteeTest < Test::Unit::TestCase
  def setup
    @invitation = Invitation.create(:attendees => 'Bassie, Adriaan')
  end

  def teardown
    Invitation.delete_all
  end

  it "is redirected to the actual invitation page" do
    get "/#{@invitation.id}"
    assert last_response.redirect?
    assert_equal "http://example.org/invitations/#{@invitation.id}", last_response.headers['Location']
  end

  it "sees an invitation page which indicates that they won't attend the wedding itself" do
    @invitation.update_attribute(:attending_wedding, false)
    get "/invitations/#{@invitation.id}"
    assert last_response.ok?
    assert_have_tag "form[@action=\"/invitations/#{@invitation.id}\"][@method=post]" do
      assert_have_tag 'input[@name="invitation[attending_wedding]"][@value="1"][@checked=checked]', :count => 0
      assert_have_tag 'input[@name="invitation[attending_wedding]"][@value="0"][@checked=checked]'
      assert_have_tag 'input[@name="invitation[attendees]"][@value="Bassie, Adriaan"]'
    end
  end

  it "sees an invitation page which indicates that they will attend the wedding itself" do
    @invitation.update_attribute(:attending_wedding, true)
    get "/invitations/#{@invitation.id}"
    assert last_response.ok?
    assert_have_tag "form[@action=\"/invitations/#{@invitation.id}\"][@method=post]" do
      assert_have_tag 'input[@name="invitation[attending_wedding]"][@value="1"][@checked=checked]'
      assert_have_tag 'input[@name="invitation[attending_wedding]"][@value="0"][@checked=checked]', :count => 0
      assert_have_tag 'input[@name="invitation[attendees]"][@value="Bassie, Adriaan"]'
    end
  end

  it "confirms who will be attending and that they will attend the wedding itself" do
    post "/invitations/#{@invitation.id}", :invitation => { :attending_wedding => '1', :attendees => 'Bassie, Adriaan' }
    assert last_response.redirect?
    assert_equal "http://example.org/invitations/#{@invitation.id}", last_response.headers['Location']
    assert @invitation.reload.attending_wedding?
    assert_equal %w{ Bassie Adriaan }, @invitation.attendees_list
  end

  it "confirms who will be attending and they won't attend the wedding itself" do
    post "/invitations/#{@invitation.id}", :invitation => { :attending_wedding => '0', :attendees => 'Bassie' }
    assert last_response.redirect?
    assert_equal "http://example.org/invitations/#{@invitation.id}", last_response.headers['Location']
    assert !@invitation.reload.attending_wedding?
    assert_equal %w{ Bassie }, @invitation.attendees_list
  end
end

