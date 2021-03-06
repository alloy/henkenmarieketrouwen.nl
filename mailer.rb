require 'config'
require 'helpers'
require 'mailer'

module Mailer
  class Message
    include Helpers

    def initialize(invitation)
      @invitation = invitation
    end

    class Invitation < Message
      def to_s
        dutch
      end

      def dutch
<<END_OF_MESSAGE
From: <#{FROM_EMAIL}>
To: <#{@invitation.email}>
Subject: Henk en Marieke trouwen! #{address 'Kom jij', 'Komen jullie'} ook?

Hoi #{to_sentence(@invitation.attendees_list)},

Henk en Marieke trouwen op 28 augustus 2014 en zouden #{address 'jou', 'jullie'} er graag bij hebben!
Indien #{address 'je komt', 'jullie komen'}, laat dat dan vóór 1 augustus 2014 weten via onderstaande link:

http://www.#{DOMAIN}/#{@invitation.token}

Hopelijk tot dan!
END_OF_MESSAGE
      end
    end

    class Confirmation < Message
      def subject
        if @invitation.attending?
          "Leuk dat #{address 'je komt', 'jullie komen'}!"
        else
          "Jammer dat #{address 'je niet kunt', 'jullie niet kunnen'} komen."
        end
      end

      def body
        if @invitation.attending?
          "De volgende gegevens zijn bij ons bekend:\n\n* #{summary.join("\n* ")}\n\nTot dan!"
        else
          "Zodra er foto's beschikbaar zijn laten we dat weten."
        end
      end

      def to_s
<<END_OF_MESSAGE
From: <#{FROM_EMAIL}>
To: <#{@invitation.email}>
Subject: #{subject}

#{body}
END_OF_MESSAGE
      end
    end
  end

  def self.connection
    if ENV['RACK_ENV'] == 'development'
      smtp = Object.new
      def smtp.send_message(message, from, to)
        ActiveRecord::Base.logger.info(message.to_s)
      end
      yield smtp
    else
      require 'net/smtp'
      Net::SMTP.start(SMTP_HOST, SMTP_PORT, SMTP_HELO, SMTP_USER, SMTP_PASS, SMTP_AUTH) do |smtp|
        smtp.enable_tls
        yield smtp
      end
    end
  end

  def self.send_invitations(invitations)
    connection do |smtp|
      invitations.each do |invitation|
        message = Message::Invitation.new(invitation).to_s
        ActiveRecord::Base.logger.info("Sending invitation to: #{invitation.email}")
        smtp.send_message(message, FROM_EMAIL, invitation.email)
        yield invitation
      end
    end
  end

  def self.send_confirmation(invitation)
    connection do |smtp|
      message = Message::Confirmation.new(invitation).to_s
      ActiveRecord::Base.logger.info("Sending confirmation to: #{invitation.email}")
      smtp.send_message(message, FROM_EMAIL, invitation.email)
    end
  end
end
