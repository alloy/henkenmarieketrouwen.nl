require File.expand_path('../test_helper', __FILE__)

class InviteeTest < MiniTest::Spec
  include Rack::Test::Methods
  include Webrat::Matchers
  include Webrat::HaveTagMatcher

  def response_body
    last_response.body
  end

  def app
    Sinatra::Application
  end

  def setup
    @invitation = Invitation.create(:invitees => 'Bassie, Adriaan', :email => 'bassie@caravan.es', :all_festivities => true)
  end

  it "is redirected to the actual invitation page" do
    get "/#{@invitation.token}"
    assert last_response.redirect?
    assert_equal "http://example.org/invitations/#{@invitation.token}", last_response.headers['Location']
  end

  it "sees an invitation page" do
    get "/invitations/#{@invitation.token}"
    assert last_response.ok?
    assert_have_tag "form[@action=\"/invitations/#{@invitation.token}\"][@method=post]" do
      assert_have_tag 'input[@name="invitation[attendees][]"][@value="Bassie"]'
      assert_have_tag 'input[@name="invitation[attendees][]"][@value="Adriaan"]'
      assert_have_tag 'input[@name="invitation[email]"][@value="bassie@caravan.es"]'
    end
  end

  it "confirms who will be attending" do
    update_invitation :attendees => %w{ Bassie Adriaan }
    assert_equal %w{ Bassie Adriaan }, @invitation.attendees_list
    update_invitation :attendees => %w{ Bassie }
    assert_equal %w{ Bassie }, @invitation.attendees_list
  end

  it "confirms if they'll attend the wedding itself" do
    update_invitation :attending_wedding => '0'
    assert !@invitation.attending_wedding?
    update_invitation :attending_wedding => '1'
    assert @invitation.attending_wedding?
  end

  #it "confirms if they'll attend the party" do
    #update_invitation :attending_party => '0'
    #assert !@invitation.attending_party?
    #update_invitation :attending_party => '1'
    #assert @invitation.attending_party?
  #end

  #it "confirms if they'll attend dinner" do
    #update_invitation :attending_dinner => '0'
    #assert !@invitation.attending_dinner?
    #update_invitation :attending_dinner => '1'
    #assert @invitation.attending_dinner?
  #end

  it "confirms how many vegetarians there are" do
    update_invitation :vegetarians => '0', :confirmed => '0'
    assert_equal 0, @invitation.vegetarians
    update_invitation :vegetarians => '2', :confirmed => '0'
    assert_equal 2, @invitation.vegetarians
  end

  it "shows the form with validation errors" do
    post "/invitations/#{@invitation.token}", :invitation => { :attendees => nil, :vegetarians => 3 }
    assert last_response.ok?
    assert_have_tag 'li', :content => "Er kunnen niet meer vegetariërs (3) dan gasten (0) zijn."
    assert_have_tag "form[@action=\"/invitations/#{@invitation.token}\"][@method=post]" do
      assert_have_tag 'input[@name="invitation[vegetarians]"][@value="3"]'
    end
    assert_equal 0, @invitation.reload.vegetarians
  end

  it "sees a confirmation page" do
    get "/invitations/#{@invitation.token}/confirm"
    assert last_response.ok?
    assert_have_tag "form[@action=\"/invitations/#{@invitation.token}\"][@method=post]" do
      assert_have_tag 'input[@name="invitation[confirmed]"][@value="1"]'
    end
  end

  after do
    Net::SMTP.sent_emails.clear
  end

  it "confirms that they will come" do
    @invitation.update_attribute(:attending_wedding, true)
    update_invitation({ :confirmed => '1' })
    assert @invitation.confirmed?
    emails = Net::SMTP.sent_emails
    assert_equal 1, emails.size
    assert_equal FROM_EMAIL, emails[0].from
    assert_equal @invitation.email, emails[0].to
    assert emails[0].message.include?('Leuk')
  end

  it "confirms that they will not come" do
    update_invitation({ :confirmed => '1' })
    assert @invitation.confirmed?
    emails = Net::SMTP.sent_emails
    assert_equal 1, emails.size
    assert_equal FROM_EMAIL, emails[0].from
    assert_equal @invitation.email, emails[0].to
    assert emails[0].message.include?('Jammer')
  end

  it "does not send a confirmation email if there is no address" do
    @invitation.update_attribute(:email, nil)
    update_invitation({ :confirmed => '1' })
    assert @invitation.confirmed?
    assert Net::SMTP.sent_emails.empty?
  end

  #it "shows a confirmed invitation page" do
    #@invitation.update_attribute(:confirmed, true)
    #get "/invitations/#{@invitation.token}"
    #assert last_response.ok?
    #assert_have_tag "form", :count => 0
  #end

  it "addresses the invitee(s) in the proper way" do
    get "/invitations/#{@invitation.token}"
    assert last_response.body.include?('komen jullie')
    assert !last_response.body.include?('kom je')
    @invitation.send(:write_attribute, :invitees, 'Bassie')
    @invitation.send(:write_attribute, :attendees, 'Bassie')
    @invitation.save
    get "/invitations/#{@invitation.token}"
    assert !last_response.body.include?('komen jullie')
    assert last_response.body.include?('kom je')
  end

  it "returns a 404 when an invitation can't be found by token" do
    get "/invitations/doesnotexist"
    assert last_response.not_found?
    get "/invitations/doesnotexist/confirm"
    assert last_response.not_found?
    post "/invitations/doesnotexist"
    assert last_response.not_found?
  end

  it "sees a present page" do
    get "/present"
    assert last_response.ok?
  end

  it "sees a contact page" do
    get "/contact"
    assert last_response.ok?
  end

  private

  def update_invitation(invitation_attributes, redirect_to = nil)
    if invitation_attributes[:confirmed].nil? && invitation_attributes[:attendees].nil?
      invitation_attributes[:attendees] = @invitation.attendees_list
    end
    post "/invitations/#{@invitation.token}", :invitation => invitation_attributes
    assert last_response.redirect?
    assert_equal(redirect_to || "http://example.org/invitations/#{@invitation.token}/confirm", last_response.headers['Location'])
    @invitation.reload
  end
end

