require "rails_helper"

RSpec.describe "New Application Form", type: :feature do
  before :each do
    @app1 = Application.create!({name: "Charles", address: "123 S Monroe", city: "Denver", state: "CO", zip: "80102", description: "Good home for good boy", status: "In Progress"})
    @app2 = Application.create!({name: "TP", address: "1080 Pronghorn", city: "Del Norte", state: "CO", zip: "81132", description: "Good home for good boy", status: "In Progress"})
    @s1 = Shelter.create!({foster_program: true, name: "Paw Patrol", city: "Denver", rank: 2})
    @p1 = Pet.create!({name: "Buster", adoptable: true, age: 7, breed: "mut", shelter_id: @s1.id})
    @p2 = Pet.create!({name: "Kyo", adoptable: false, age: 1, breed: "calico", shelter_id: @s1.id})
    PetApplication.create!(application: @app1, pet: @p2)
    PetApplication.create!(application: @app2, pet: @p1)
  end

  describe "As a visitor" do
    describe "when I visit /applications index page" do
      # US 2 Part 2
      it "displays a form to create a new application" do
        # As a visitor
        # When I visit the pet index page
        # Then I see a link to "Start an Application"
        # When I click this link
        # Then I am taken to the new application page where I see a form
        # When I fill in this form with my:
        #   - Name
        #   - Street Address
        #   - City
        #   - State
        #   - Zip Code
        #   - Description of why I would make a good home
        # And I click submit
        # Then I am taken to the new application's show page
        # And I see my Name, address information, and description of why I would make a good home
        # And I see an indicator that this application is "In Progress"

        visit "/applications/new"

        fill_in "Name", with: "Roman"
        fill_in "Street Address", with: "444 Berry Way"
        fill_in "City", with: "Boulder"
        fill_in "State", with: "CO"
        fill_in "Zip", with: "88888"
        fill_in "Description of why I would make a good home", with: "A loving family."
        fill_in "Status", with: "In Progress"
        click_button "Submit"

        expect(current_path).to eq("/applications/#{@app2.id + 1}")

        expect(page).to have_content("Roman")
        expect(page).to have_content("444 Berry Way")
        expect(page).to have_content("A loving family")
        expect(page).to have_content("In Progress")
      end
    end

    # US 3
    it "handles invalid input in the new form field" do
      # As a visitor
      # When I visit the new application page
      # And I fail to fill in any of the form fields
      # And I click submit
      # Then I am taken back to the new applications page
      # And I see a message that I must fill in those fields.
  
      visit "/applications/new"
  
      fill_in "Name", with: "Sir TP"
  
      click_button "Submit"
      
      expect(current_path).to eq("/applications/new")
      expect(page).to have_content("Each field must be complete")
    end
  end
end
