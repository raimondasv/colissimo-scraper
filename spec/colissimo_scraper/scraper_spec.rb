require 'spec_helper'

describe ColissimoScraper do

  describe "#fetch_tracking_list" do

    let(:bytes) { File.binread(File.dirname(__FILE__) + '/assets/' + file) }
    let(:tracker) { ColissimoScraper.fetch_tracking_list(parcel_number) }

    xcontext "call actual service" do

      context "for valid number" do
        let(:parcel_number) { '8J00289215218' }
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

    context "with mocked" do
      let(:parcel_number) { '8J00111111111'}

      before do
        expect(ColissimoScraper).to receive(:get_page_response).with('8J00111111111').and_return('fake_content')

        expect_any_instance_of(ColissimoScraper::PageParser).to receive(:fetch_images).and_return(
          [ {src: 'fake_url', field: ColissimoScraper::DESCR_FIELD_URL, index: 1} ]
        )
        expect_any_instance_of(ColissimoScraper::ImageHashTracker).to receive(:get_image).and_return(bytes)
      end

      context "unrecognized state" do
        let(:bytes) { 'unrecognized_bytes '}
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::UNRECOGNISED) }
      end

      context "'Your parcel was delivered to the caretaker or frontdesk' state" do
        let(:file) { 'frontdesk.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::DELIVERED) }
      end

      context "'Your parcel is ready for delivery' state" do
        let(:file) { 'delivery.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::ON_DELIVERY) }
      end

      context "'Your parcel has arrived at its delivery location' state" do
        let(:file) { 'location.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::IN_TRANSIT) }
      end

      context "'La Poste is handling your parcel. It is currently being routed.' state" do
        let(:file) { 'routed.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::IN_TRANSIT) }
      end

      context "'You parcel has been dropped-off at the shipping post office' state" do
        let(:file) { 'dropped.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::IN_TRANSIT) }
      end

      context "'Your parcel is ready to be shipped. It has not been taken on by La Poste yet.' state" do
        let(:file) { 'shipped.png'  }
        subject(:track_list) { tracker.tracking_list }
        it { expect { |b| track_list.map(&:status).each(&b) }.to yield_successive_args(ColissimoScraper::Status::IN_TRANSIT) }
      end
    end

    context "mock base page responses" do

      let(:page_parser) { ColissimoScraper::PageParser.new(bytes) }

      context "and expect usual response" do
        let(:file) { 'delivered_request.html' }
        subject(:images) { page_parser.fetch_images }

        it "with filled image array" do
          expect(images.size).to be(21)

          idx = 1
          images.each_slice(3) do |sample|
            sample.each do |item|
              expect(item[:index]).to be(idx)
              expect(item[:field]).to eq(ColissimoScraper::DATE_FIELD_URL) |
                eq(ColissimoScraper::SITE_FIELD_URL) |
                eq(ColissimoScraper::DESCR_FIELD_URL)
              expect(item[:src]).not_to be_empty
            end
            idx += 1
          end
        end

        it "should have statuses" do
          expect(page_parser.contains_statuses?).to be(true)
        end
      end

      context "and expect response with errors" do
        shared_examples 'no statuses' do
          it {
            expect(page_parser.fetch_images).to be_empty
            expect(page_parser.contains_statuses?).to be(false)
          }
        end

        let(:file) { 'old_tracking_number.html' }
        it_behaves_like 'no statuses'


        let(:file) { 'unknown_number.html' }
        it_behaves_like 'no statuses'

        let(:file) { 'invalid_number.html' }
        it_behaves_like 'no statuses'
      end
    end

    context "should react to exception" do
      before { expect(ColissimoScraper).to receive(:get_page_response).and_raise(RestClient::Exception, "Oops") }

      it "and wrap the exception" do
        expect{ ColissimoScraper.fetch_tracking_list('8J00289215218') }.to raise_error(ColissimoScraper::ScrapingError)
      end
    end
  end
end
