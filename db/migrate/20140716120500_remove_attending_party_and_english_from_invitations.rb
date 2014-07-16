class RemoveAttendingPartyAndEnglishFromInvitations < ActiveRecord::Migration
  def change
    remove_column :invitations, :attending_party
    remove_column :invitations, :english
  end
end

