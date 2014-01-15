require 'spec_helper'

describe PlaceObserver do
  it "should invalidate the cache for the references that use the place" do
    place = FactoryGirl.create :place
    publisher = FactoryGirl.create :publisher, place: place
    references = []
    (0..2).each do |i|
      if i < 2
        references[i] = FactoryGirl.create :book_reference, publisher: publisher
      else
        references[i] = FactoryGirl.create :book_reference
      end
      references[i].populate_cache
    end

    references[0].formatted_cache.should_not be_nil
    references[1].formatted_cache.should_not be_nil
    references[2].formatted_cache.should_not be_nil

    PlaceObserver.instance.before_update place

    references[0].reload.formatted_cache.should be_nil
    references[1].reload.formatted_cache.should be_nil
    references[2].reload.formatted_cache.should_not be_nil
  end
end
