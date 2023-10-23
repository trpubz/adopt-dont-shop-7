class CreateApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :applications do |t|
      t.string :name
      t.string :address
      t.string :address_s
      t.string :city
      t.string :state
      t.string :zip
      t.string :description
      t.string :status

      t.timestamps
    end
  end
end
