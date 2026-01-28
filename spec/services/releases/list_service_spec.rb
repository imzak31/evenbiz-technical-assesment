# frozen_string_literal: true

require "rails_helper"

RSpec.describe Releases::ListService do
  describe ".call" do
    subject(:result) { described_class.call(params: params) }

    let(:params) { {} }

    context "when there are no releases" do
      it "returns success with empty data" do
        expect(result).to be_success
        expect(result.data).to be_empty
      end

      it "returns pagination meta" do
        expect(result.meta).to be_a(PaginationMeta)
        expect(result.meta.total_count).to eq(0)
      end
    end

    context "with releases" do
      before { create_list(:release, 3) }

      it "returns success" do
        expect(result).to be_success
      end

      it "returns all releases" do
        expect(result.data.count).to eq(3)
      end

      it "returns a ServiceResult" do
        expect(result).to be_a(ServiceResult)
      end
    end

    describe "ordering" do
      let!(:older) { create(:release, name: "Older", released_at: 2.days.ago) }
      let!(:newer) { create(:release, name: "Newer", released_at: 1.day.ago) }

      it "returns releases ordered by released_at desc" do
        expect(result.data.map(&:id)).to eq([ newer.id, older.id ])
      end

      context "with same released_at" do
        before do
          create(:release, name: "Zulu", released_at: newer.released_at)
          create(:release, name: "Alpha", released_at: newer.released_at)
        end

        it "orders by name asc as secondary sort" do
          names_at_same_date = result.data
            .select { |r| r.released_at == newer.released_at }
            .map(&:name)

          expect(names_at_same_date).to eq(%w[Alpha Newer Zulu])
        end
      end
    end

    describe "past filter" do
      let!(:past_release) { create(:release, released_at: 1.day.ago) }
      let!(:future_release) { create(:release, released_at: 1.day.from_now) }

      context "when past is nil" do
        let(:params) { { past: nil } }

        it "returns all releases" do
          expect(result.data).to include(past_release, future_release)
        end
      end

      context "when past is '1'" do
        let(:params) { { past: "1" } }

        it "returns only past releases" do
          expect(result.data).to include(past_release)
          expect(result.data).not_to include(future_release)
        end
      end

      context "when past is 'true'" do
        let(:params) { { past: "true" } }

        it "returns only past releases" do
          expect(result.data).to include(past_release)
          expect(result.data).not_to include(future_release)
        end
      end

      context "when past is '0'" do
        let(:params) { { past: "0" } }

        it "returns only upcoming releases" do
          expect(result.data).to include(future_release)
          expect(result.data).not_to include(past_release)
        end
      end

      context "when past is 'false'" do
        let(:params) { { past: "false" } }

        it "returns only upcoming releases" do
          expect(result.data).to include(future_release)
          expect(result.data).not_to include(past_release)
        end
      end

      context "when past is invalid" do
        let(:params) { { past: "invalid" } }

        it "returns all releases" do
          expect(result.data).to include(past_release, future_release)
        end
      end
    end

    describe "pagination" do
      before { create_list(:release, 15) }

      context "with default pagination" do
        it "returns first 10 releases" do
          expect(result.data.count).to eq(10)
        end

        it "includes pagination meta" do
          expect(result.meta.current_page).to eq(1)
          expect(result.meta.total_count).to eq(15)
          expect(result.meta.total_pages).to eq(2)
          expect(result.meta.per_page).to eq(10)
        end
      end

      context "with page param" do
        let(:params) { { page: 2 } }

        it "returns second page" do
          expect(result.data.count).to eq(5)
          expect(result.meta.current_page).to eq(2)
        end
      end

      context "with limit param" do
        let(:params) { { limit: 5 } }

        it "returns specified number of releases" do
          expect(result.data.count).to eq(5)
          expect(result.meta.per_page).to eq(5)
        end
      end

      context "with limit exceeding max" do
        let(:params) { { limit: 200 } }

        it "caps at MAX_PER_PAGE (100)" do
          expect(result.meta.per_page).to eq(100)
        end
      end

      context "with negative limit" do
        let(:params) { { limit: -5 } }

        it "falls back to default" do
          expect(result.meta.per_page).to eq(10)
        end
      end

      context "with zero limit" do
        let(:params) { { limit: 0 } }

        it "falls back to default" do
          expect(result.meta.per_page).to eq(10)
        end
      end

      context "with non-numeric limit" do
        let(:params) { { limit: "abc" } }

        it "falls back to default" do
          expect(result.meta.per_page).to eq(10)
        end
      end
    end

    describe "combined filters and pagination" do
      before do
        create_list(:release, 12, :past)
        create_list(:release, 5, :upcoming)
      end

      context "with past filter and pagination" do
        let(:params) { { past: "1", page: 2, limit: 5 } }

        it "paginates filtered results" do
          expect(result.data.count).to eq(5)
          expect(result.meta.total_count).to eq(12)
          expect(result.meta.total_pages).to eq(3)
        end
      end
    end
  end
end
