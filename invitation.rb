require 'config'
require 'securerandom'
require 'mailer'
require 'validates_email_san'

class Invitation < ActiveRecord::Base
  def self.send_invitations!
    invitations = where(:sent => false).where(arel_table[:email].not_eq(nil))
    Mailer.send_invitations(invitations) do |invitation|
      invitation.update_attribute(:sent, true)
    end
  end

  before_save :ensure_attending_party_if_attending_dinner
  before_create :set_token

  after_initialize do |invitation|
    if invitation.new_record?
      self.attendees = invitees
      if invitation.all_festivities?
        self.attending_wedding = true
        self.attending_dinner = true
      end
      self.attending_brunch = true
      self.attending_party_on_day_1 = true
      self.attending_party_on_day_2 = true
    end
  end

  def all_festivities=(flag)
    if new_record?
      write_attribute(:all_festivities, flag)
    else
      raise "Not allowed to change all_festivities!"
    end
  end

  def email=(address)
    if address && address.strip.empty?
      address = nil
    end
    write_attribute(:email, address)
  end

  def vegetarians=(amount)
    write_attribute(:vegetarians, amount.to_i)
  end

  def omnivores
    attendees_list.size - vegetarians
  end

  def ensure_attending_party_if_attending_dinner
    self.attending_party = true if attending_dinner?
  end

  def attendees=(attendees)
    write_attribute(:attendees, list(attendees).reject(&:empty?).join(", "))
  end

  def invitees=(invitees)
    if new_record?
      write_attribute(:invitees, invitees.strip)
    else
      raise "Not allowed to change invitees!"
    end
  end

  def attendees_list
    list(attendees)
  end

  def invitees_list
    list(invitees)
  end

  def attendees_sentence
    list = attendees_list
    if list.size == 1
      list.first
    else
      list[0..-2].join(", ") << "#{english? ? ', and' : ' en'} #{list.last}"
    end
  end

  def attending?
    attending_wedding? || attending_party?
  end

  private

  def list(str)
    str.split(",").map { |a| a.strip }
  end

  def set_token
    token = nil
    loop do
      token = generate_token
      break if Invitation.find_by_token(token).nil?
    end
    write_attribute :token, token
  end

  def generate_token
    SecureRandom.hex(6)
  end

  def amount_of_vegetarians
    if vegetarians < 0
      errors.add(:vegetarians, "Het aantal vegetariërs kan niet negatief zijn.")
    elsif vegetarians > attendees_list.size
      errors.add(:vegetarians, "Er kunnen niet meer vegetariërs (#{vegetarians}) dan gasten (#{attendees_list.size}) zijn.")
    end
  end

  def allowed_festivities
    unless all_festivities?
      if attending_wedding?
        errors.add(:attending_wedding, "U bent niet uitgenodigd voor de bruiloft ceremonie.")
      end
      if attending_dinner?
        errors.add(:attending_wedding, "U bent niet uitgenodigd voor het diner.")
      end
    end
  end

  validate :allowed_festivities
  validates_presence_of :attendees, :message => "De gastenlijst mag niet leeg zijn."
  validate :amount_of_vegetarians
  validates_email :email, :allow_nil => true, :message => "Het opgegeven email adres is niet valide."
end
