require "rails_helper"

RSpec.describe Shelter, type: :model do
  describe "relationships" do
    it { should have_many(:pets) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:rank) }
    it { should validate_numericality_of(:rank) }
  end

  before(:each) do
    @shelter_1 = Shelter.create(name: "Aurora shelter", city: "Aurora, CO", foster_program: false, rank: 9)
    @shelter_2 = Shelter.create(name: "RGV animal shelter", city: "Harlingen, TX", foster_program: false, rank: 5)
    @shelter_3 = Shelter.create(name: "Fancy pets of Colorado", city: "Denver, CO", foster_program: true, rank: 10)

    @pet_1 = @shelter_1.pets.create(name: "Mr. Pirate", breed: "tuxedo shorthair", age: 5, adoptable: false)
    @pet_2 = @shelter_1.pets.create(name: "Clawdia", breed: "shorthair", age: 3, adoptable: true)
    @pet_3 = @shelter_3.pets.create(name: "Lucille Bald", breed: "sphynx", age: 8, adoptable: true)
    @pet_4 = @shelter_1.pets.create(name: "Ann", breed: "ragdoll", age: 5, adoptable: true)
  end

  describe "class methods" do
    describe "#search" do
      it "returns partial matches" do
        expect(Shelter.search("Fancy")).to eq([@shelter_3])
      end
    end

    describe "#order_by_recently_created" do
      it "returns shelters with the most recently created first" do
        expect(Shelter.order_by_recently_created).to eq([@shelter_3, @shelter_2, @shelter_1])
      end
    end

    describe "#order_by_number_of_pets" do
      it "orders the shelters by number of pets they have, descending" do
        expect(Shelter.order_by_number_of_pets).to eq([@shelter_1, @shelter_3, @shelter_2])
      end
    end

    describe "#reverse_ordered" do
      it "orders by name in reverse alphabetical order" do
        # As a visitor
        # When I visit the admin shelter index ('/admin/shelters')
        # Then I see all Shelters in the system listed in reverse alphabetical order by name
        expect(Shelter.reverse_ordered).to eq [@shelter_2, @shelter_3, @shelter_1]
      end
    end

    describe "#pending_applications" do
      it "returns all distinct shelters that have atleast one application with status pending" do
        # Shelters
        @shelter_1 = Shelter.create(name: "Aurora shelter", city: "Aurora, CO", foster_program: false, rank: 9)
        @shelter_2 = Shelter.create(name: "RGV animal shelter", city: "Harlingen, TX", foster_program: false, rank: 5)
        @shelter_3 = Shelter.create(name: "Fancy pets of Colorado", city: "Denver, CO", foster_program: true, rank: 10)
        @shelter_4 = Shelter.create(name: "Small Paws Rescue", city: "Boulder, CO", foster_program: true, rank: 7)

        # Pets
        @s1_p1 = @shelter_1.pets.create(name: "Mr. Pirate", breed: "tuxedo shorthair", age: 5, adoptable: true)
        @s1_p2 = @shelter_1.pets.create(name: "Clawdia", breed: "shorthair", age: 3, adoptable: true)
        @s3_p1 = @shelter_3.pets.create(name: "Lucille Bald", breed: "sphynx", age: 8, adoptable: true)
        @s4_p1 = @shelter_4.pets.create(name: "Whiskers", breed: "siamese", age: 2, adoptable: true)

        # Applications
        @app1 = Application.create!({name: "Charles", address: "123 S Monroe", city: "Denver", state: "CO", zip: "80102",
                                  description: "Good home for good boy", status: "In Progress"})
        @app2 = Application.create!({name: "TP", address: "1080 Pronghorn", city: "Del Norte", state: "CO", zip: "81132",
                                  description: "Good home for good boy", status: "Pending"})
        @app3 = Application.create!({name: "Alice", address: "456 N Lincoln", city: "Aurora", state: "CO", zip: "80203",
                                  description: "I love cats", status: "Accepted"})
        @app4 = Application.create!({name: "Bob", address: "789 W Colfax", city: "Denver", state: "CO", zip: "80204",
                                  description: "Dogs are my favorite", status: "Pending"})
        @app5 = Application.create!({name: "Eve", address: "111 E 3rd Ave", city: "Denver", state: "CO", zip: "80205",
                                  description: "Looking for a buddy", status: "Pending"})

        # Pet-Application links
        PetApplication.create!(application: @app1, pet: @s1_p2)
        PetApplication.create!(application: @app2, pet: @s1_p1)
        PetApplication.create!(application: @app3, pet: @s3_p1)
        PetApplication.create!(application: @app4, pet: @s4_p1)
        PetApplication.create!(application: @app5, pet: @s1_p2)
        
        # US 11
        # As a visitor
        # When I visit the admin shelter index ('/admin/shelters')
        # Then I see a section for "Shelters with Pending Applications"
        # And in this section I see the name of every shelter that has a pending application
        # require 'pry';binding.pry
        expect(Shelter.pending_applications).to eq([@shelter_1, @shelter_4])
      end
    end
  end

  describe "instance methods" do
    describe "#adoptable_pets" do
      it "only returns pets that are adoptable" do
        expect(@shelter_1.adoptable_pets).to eq([@pet_2, @pet_4])
      end
    end

    describe "#alphabetical_pets" do
      it "returns pets associated with the given shelter in alphabetical name order" do
        expect(@shelter_1.alphabetical_pets).to eq([@pet_4, @pet_2])
      end
    end

    describe "#shelter_pets_filtered_by_age" do
      it "filters the shelter pets based on given params" do
        expect(@shelter_1.shelter_pets_filtered_by_age(5)).to eq([@pet_4])
      end
    end

    describe "#pet_count" do
      it "returns the number of pets at the given shelter" do
        expect(@shelter_1.pet_count).to eq(3)
      end
    end
  end
end
