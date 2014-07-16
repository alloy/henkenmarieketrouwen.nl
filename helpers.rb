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

  def checkbox_tag(name, label, value, checked)
    %{<label>
        <input type="checkbox" name="#{name}" value="#{value}" #{'checked="checked"' if checked} />
        #{label}
      </label>}
  end

  def checkbox(attr, label)
    %{<input type="hidden" name="invitation[#{attr}]" value="0" />#{checkbox_tag("invitation[#{attr}]", label, '1', @invitation.send(attr))}}
  end

  def summary
    result = []
    result << "#{to_sentence(@invitation.attendees_list)}."

    day_1 = []
    day_1 << 'de ceremonie om 18:30 uur' if @invitation.attending_wedding?
    day_1 << 'buffet om 20:00 uur' if @invitation.attending_dinner?
    day_1 << 'het feest vanaf 21:00 uur' if @invitation.attending_party_on_day_1?
    if day_1.empty?
      result << "#{address 'Is', 'Zijn'} niet aanwezig op 28 augustus."
    else
      result << "#{address 'Is', 'Zijn'} aanwezig op 28 augustus tijdens #{to_sentence(day_1)}."
    end

    day_2 = []
    day_2 << 'programma vanaf 11:30 uur' if @invitation.attending_party_on_day_2?
    day_2 << 'de brunch om 12:00 uur' if @invitation.attending_brunch?
    if day_2.empty?
      result << "#{address 'Is', 'Zijn'} niet aanwezig op 29 augustus."
    else
      result << "#{address 'Is', 'Zijn'} aanwezig op 29 augustus tijdens #{to_sentence(day_2)}."
    end

    if @invitation.attending_dinner?
      if (omnivores = @invitation.omnivores) > 0
        result << "#{omnivores} #{address 'persoon eet', "personen eten", omnivores} vlees."
      end
      if (vegetarians = @invitation.vegetarians) > 0
        result << "#{vegetarians} #{address 'persoon is', "personen zijn", vegetarians} #{address 'vegetariër', 'vegetariërs', vegetarians}."
      end
    end

    if @invitation.note.present?
      result << "Opmerking: #{@invitation.note}"
    end
    result
  end
end
