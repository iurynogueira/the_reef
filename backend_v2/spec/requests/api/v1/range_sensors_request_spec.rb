# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::RangeSensors" do
  describe "GET /api/v1/range_sensors" do
    let(:do_request) { get "/api/v1/range_sensors", headers:, params: }

    let(:params) { {} }

    context "when user is authenticated" do
      let(:user) { create(:user, admin: true) }
      let(:headers) { auth_headers_for(user) }

      context "when has no page or per_page params" do
        let!(:range_sensor) { create(:range_sensor, user:) }

        before do
          create_list(:range_sensor, 2)
          do_request
        end

        it { expect(response).to have_http_status(:ok) }

        it "returns range_sensors" do
          expected_response = [
            {
              id: range_sensor.id,
              name: range_sensor.name,
              description: range_sensor.description,
              min_value: range_sensor.min_value.to_s,
              max_value: range_sensor.max_value.to_s,
              numeric_value_on_range: false,
              numeric_value_over_range: false,
              numeric_value_under_range: false,
              numeric_values: [],
              current_numeric_value: nil
            }.with_indifferent_access
          ]

          expect(response.parsed_body).to eq(expected_response)
        end
      end

      context "when has page and per_page params" do
        let(:params) { { page: 1, per_page: 5 } }

        before do
          create_list(:range_sensor, 6, user:)
          do_request
        end

        it { expect(response).to have_http_status(:ok) }

        it "returns range_sensors according to pagination" do
          expect(response.parsed_body.count).to eq(5)
        end
      end

      context "when has values_amount params" do
        let(:params) { { values_amount: 2 } }
        let(:range_sensor) { create(:range_sensor, user:) }
        let(:first_numeric_value) do
          create(:numeric_value, range_sensor:, created_at: Time.zone.now)
        end
        let(:second_numeric_value) do
          create(:numeric_value, range_sensor:, created_at: 1.day.from_now)
        end
        let(:third_numeric_value) do
          create(:numeric_value, range_sensor:, created_at: 2.days.from_now)
        end

        let(:numeric_values) { [first_numeric_value, second_numeric_value, third_numeric_value] }

        before do
          numeric_values
          do_request
        end

        it { expect(response).to have_http_status(:ok) }

        it "returns numeric_values according to values_amount" do
          expected_response = [
            {
              id: range_sensor.id,
              name: range_sensor.name,
              description: range_sensor.description,
              min_value: range_sensor.min_value.to_s,
              max_value: range_sensor.max_value.to_s,

              numeric_value_on_range: false,
              numeric_value_over_range: true,
              numeric_value_under_range: false,
              numeric_values: [
                {
                  id: second_numeric_value.id,
                  value: second_numeric_value.value.to_s,
                  created_at: second_numeric_value.created_at.strftime("%Y-%m-%d %H:%M:%S")
                },
                {
                  id: third_numeric_value.id,
                  value: third_numeric_value.value.to_s,
                  created_at: third_numeric_value.created_at.strftime("%Y-%m-%d %H:%M:%S")
                }
              ],
              current_numeric_value:
                {
                  id: third_numeric_value.id,
                  value: third_numeric_value.value.to_s,
                  created_at: third_numeric_value.created_at.strftime("%Y-%m-%d %H:%M:%S")
                }
            }.with_indifferent_access
          ]
          expect(response.parsed_body).to eq(expected_response)
        end

        it "returns only 2 numeric_values" do
          expect(json_response[0][:numeric_values].count).to eq(2)
        end
      end
    end

    context "when user unauthenticated" do
      context "when has user" do
        before { do_request }

        it { expect(response).to have_http_status(:unauthorized) }

        it {
          expect(response.parsed_body["error"]).to eq("invalid_token")
        }
      end
    end
  end
end
