class AddUserToSaves < ActiveRecord::Migration[7.1]
  def change
    add_reference :saves, :user, foreign_key: true
  end
end
