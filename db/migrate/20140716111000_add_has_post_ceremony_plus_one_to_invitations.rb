class AddHasPostCeremonyPlusOneToInvitations < ActiveRecord::Migration
  def change
    change_table :invitations do |t|
      t.boolean :has_post_ceremony_plus_one, :default => false
    end
  end
end

