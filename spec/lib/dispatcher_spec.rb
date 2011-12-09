require_relative '../spec_helper'

class APIAdapter1 <  Tom::Adapter
  register_route "^/manatees/[0-9]+$"
  def handle(env);end
end
APIAdapter1.host = 'http://api_host_1.com'

class APIAdapter2 <  Tom::Adapter
  register_route "^/manatees/[0-9]+$"
  def handle(env);end
end
APIAdapter2.host = 'http://api_host_2.com'


describe Tom do

  before(:each) do

  end

  it "emits a 200 even when there are no adapters for the route" do
    with_api(Tom::GoliathAPI) do
      request = get_request(:path => '/walruses/5')
      request.response_header.status.should == 200
    end
  end

  it "emits a 404 when there are no mergers for the route" do
    with_api(Tom::GoliathAPI) do
      request = get_request(:path => '/')
      request.response_header.status.should == 404
    end
  end

  it "makes requests to all registered adapters" do
    expected_rack_env = hash_including("REQUEST_URI"    => "/manatees/15",
                                       "REQUEST_METHOD" => "GET")

    APIAdapter1.any_instance.should_receive(:handle).with(expected_rack_env).and_return true
    APIAdapter2.any_instance.should_receive(:handle).with(expected_rack_env).and_return true

    with_api(Tom::GoliathAPI) do
      request = get_request(:path => '/manatees/15')
    end
  end

  # Until we figure out how to properly mock EM:HttpRequest's with em-synchrony
  # and Webmock, testing doesn't make too much sense here. So we'll discard it
  # until then.
  it "merges the result"
end
