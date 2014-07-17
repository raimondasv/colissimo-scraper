require 'spec_helper'

describe ColissimoScraper do

  describe ".get_tracking_list" do

    let(:tracker) { ColissimoScraper.get_tracking_list(parcel_number) }

    context "call actual service" do

      context "for valid number" do
        let(:parcel_number) { '8J00288349136' }
        subject (:track_list) { tracker.tracking_list }

        it "should be delivered" do
          expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::DELIVERED)
        end
      end

      context "for other valid number" do
        let(:parcel_number) { '8J00288349136' }
        subject (:track_list) { tracker.tracking_list }

        it "should be delivered" do
          expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::DELIVERED)
        end
      end

      context "for invalid number" do
        let(:parcel_number) { '8J00589214461' }
        subject (:track_list) { tracker.tracking_list }
        it { should eq([]) }
      end

      context "for valid, but unknown number" do
        let(:parcel_number) { '8J00589214461' }
        subject (:track_list) { tracker.tracking_list }
        it { should eq([]) }
      end
    end

    context "invalid input" do

      let(:parcel_number) { 'aaa' }
      it "should raise error on letters" do 
        expect{ tracker }.to raise_error(ArgumentError)
      end

      let(:parcel_number) { '' }
      it "should raise error on empty" do
        expect{ tracker }.to raise_error(ArgumentError)
      end

      let(:parcel_number) { nil }
      it "should raise error on nil" do        
        expect{ tracker }.to raise_error(ArgumentError)
      end
    end

    context "mocked states" do
      let(:parcel_number) { '8J00111111111'}
      let(:image_bytes) { File.binread(File.dirname(__FILE__) + '/assets/' + image_file) }

      before do
        expect(ColissimoScraper).to receive(:get_page_response).with('8J00111111111').and_return('fake_content')
        expect_any_instance_of(ColissimoScraper::Response).to receive(:each_image_url).and_yield(
            'fake_url', ColissimoScraper::DESCR_FIELD_URL, 1)
        expect_any_instance_of(ColissimoScraper::ImageHashTracker).to receive(:get_image).and_return(image_bytes)
      end

      context "mock unrecognized state" do
        let(:image_bytes) { 'unrecognized_bytes '}
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::UNRECOGNISED) }
      end

      context "mock 'Your parcel was delivered to the caretaker or frontdesk' state" do
        let(:image_file) { 'frontdesk.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::DELIVERED) }
      end

      context "mock 'Your parcel is ready for delivery' state" do
        let(:image_file) { 'delivery.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::ON_DELIVERY) }
      end

      context "mock 'Your parcel has arrived at its delivery location' state" do
        let(:image_file) { 'location.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::IN_TRANSIT) }
      end

      context "mock 'La Poste is handling your parcel. It is currently being routed.' state" do
        let(:image_file) { 'routed.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::IN_TRANSIT) }
      end

      context "mock 'You parcel has been dropped-off at the shipping post office' state" do
        let(:image_file) { 'dropped.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::IN_TRANSIT) }
      end

      context "mock 'Your parcel is ready to be shipped. It has not been taken on by La Poste yet.' state" do
        let(:image_file) { 'shipped.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::IN_TRANSIT) }
      end
    end
  end
end
