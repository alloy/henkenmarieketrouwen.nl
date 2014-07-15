class AddInviteesToInvitations < ActiveRecord::Migration
  def change
    change_table :invitations do |t|
      t.string :invitees, :null => false
    end
  end
end

