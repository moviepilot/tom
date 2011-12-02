require_relative '../spec_helper'

class ForwardingAdapter1 <  Tom::Adapter
  register_route "^/manatees/[0-9]+$"
  def handle(env)
    forward_request(env)
  end
end
ForwardingAdapter1.host = 'http://webmocked-host-1.com'

describe Tom::Adapter do

  let(:env){ {'REQUEST_URI'    =>  '/manatees/15?foo',
              'REQUEST_METHOD' =>  'GET'} }

  it "forward_request uses rewrite_request to change the host" do
    rewritten = {host: "http://webmocked-host-1.com", uri: "/o", method: "get" }
    ForwardingAdapter1.any_instance.should_receive(:rewrite_host).and_return(rewritten)
    with_api(Tom::GoliathAPI) do
      request = get_request(:path => '/manatees/15?foo')
    end
  end

  it "rewrite_request changes the host" do
    rewritten = ForwardingAdapter1.new.rewrite_request(env)

    rewritten[:host].should   == "http://webmocked-host-1.com"
    rewritten[:uri].should    == "/manatees/15?foo"
    rewritten[:method].should == :get
  end

  it "rubs the lotion on its skin" do
    true
  end
end
