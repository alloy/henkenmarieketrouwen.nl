class AddFestivityAttributesToInvitations < ActiveRecord::Migration
  def change
    change_table :invitations do |t|
      t.boolean :all_festivities, :default => false
      t.boolean :attending_brunch, :default => false
      t.boolean :attending_party_on_day_1, :default => false
      t.boolean :attending_party_on_day_2, :default => false
    end
  end
end
