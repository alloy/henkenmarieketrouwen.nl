module Helpers
  def to_sentence(list)
    if list.size == 1
      list.first
    else
      "#{list[0..-2].join(", ")} en #{list.last}"
    end
  end

  def header_links
    %{<h1><a href="/">&larr; Henk &amp; Marieke trouwen!</a></h1>
      <ul>
        <li><a href="/present">Cadeau</a></li>
        <li><a href="/accommodations">Overnachten</a></li>
        <li><a href="/contact">Contact</a></li>
      </ul>}
  end

  def address(singular_form, plural_form, amount = nil)
    amount ||= @invitation.invitees_list.size
    amount == 1 ? singular_form : plural_form
  end

  def update_invitation_form_tag
    %{<form action="/invitations/#{@invitation.token}" method="post">}
  end

  def textfield(attr, style)
    error = false
    if ary = @invitation.errors[attr]
      error = !ary.empty?
    end
    %{<input type="text" name="invitation[#{attr}]" value="#{@invitation.send(attr)}" #{'class="error"' if error} style="#{style}" />}
  end

  def checkbox_tag(attr, label, value, checked)
    %{<label>
        <input type="checkbox" id="#{attr}_input" name="invitation[#{attr}]" value="#{value}" #{'checked="checked"' if checked} />
        #{label}
      </label>}
  end

  def checkbox(attr, label)
    %{<input type="hidden" name="invitation[#{attr}]" value="0" />#{checkbox_tag(attr, label, '1', @invitation.send(attr))}}
  end

  def summary
    result = []
    result << "#{to_sentence(@invitation.attendees_list)}."
    if @invitation.attending_wedding? && @invitation.attending_party?
      result << "#{address 'Is', 'Zijn'} aanwezig op de bruiloft om 13:30 en het feest vanaf 15:00."
    else
      result << "#{address 'Is', 'Zijn'} alleen aanwezig op #{@invitation.attending_wedding? ? 'de bruiloft om 13:30' : 'het feest vanaf 15:00'}."
    end
    if @invitation.attending_dinner?
      if (omnivores = @invitation.omnivores) > 0
        result << "#{omnivores} #{address 'persoon maakt', "personen maken", omnivores} gebruik van de vlees BBQ."
      end
      if (vegetarians = @invitation.vegetarians) > 0
        result << "#{vegetarians} #{address 'persoon maakt', "personen maken", vegetarians} gebruik van de vegetarische BBQ."
      end
    else
      result << "#{address 'Je maakt', 'Jullie maken'} geen gebruik van de BBQ."
    end
    if @invitation.note.present?
      result << "Opmerking: #{@invitation.note}"
    end
    result
  end
end
