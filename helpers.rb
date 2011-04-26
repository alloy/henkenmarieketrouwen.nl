module Helpers
  def address(singular_form, plural_form, amount = nil)
    amount ||= @invitation.attendees_list.size
    amount == 1 ? singular_form : plural_form
  end

  def update_invitation_form_tag
    %{<form action="/invitations/#{@invitation.id}" method="post">}
  end

  def textfield(attr, style)
    error = false
    if ary = @invitation.errors[attr]
      error = !ary.empty?
    end
    %{<input type="text" name="invitation[#{attr}]" value="#{@invitation.send(attr)}" #{'class="error"' if error} style="#{style}" />}
  end

  def checkbox(attr, label)
    %{<input type="hidden" name="invitation[#{attr}]" value="0" />
      <label>
        <input type="checkbox" id="#{attr}_input" name="invitation[#{attr}]" value="1" #{'checked="checked"' if @invitation.send(attr)} />
        #{label}
      </label>}
  end

  def summary
    result = []
    result << "#{@invitation.attendees_sentence}."
    if @invitation.attending_wedding? && @invitation.attending_party?
      result << "#{address 'Is', 'Zijn'} aanwezig op de bruiloft en het feest."
    else
      result << "#{address 'Is', 'Zijn'} alleen aanwezig op #{@invitation.attending_wedding? ? 'de bruiloft' : 'het feest'}."
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
    result
  end
end
