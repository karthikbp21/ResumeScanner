require "test_helper"

class CandidatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get candidates_index_url
    assert_response :success
  end

  test "should get scan_resumes" do
    get candidates_scan_resumes_url
    assert_response :success
  end

  test "should get download_excel" do
    get candidates_download_excel_url
    assert_response :success
  end

  test "should get query" do
    get candidates_query_url
    assert_response :success
  end
end
