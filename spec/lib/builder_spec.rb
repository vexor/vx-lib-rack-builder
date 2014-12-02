require 'spec_helper'

describe Vx::Lib::Rack::Builder do
  First = Struct.new(:app) do
    def call(env)
      env << 'first.begin'
      app.call(env)
      env << 'first.end'
    end
  end

  Last = Struct.new(:app) do
    def call(env)
      env << 'last.begin'
      app.call(env)
      env << 'last.end'
    end
  end

  let(:builder) {
    described_class.new do
      use First
      use Last
    end
  }

  subject { builder }

  it "should be work" do
    env = []
    app = ->(c){ c << 'run' }
    rs = builder.to_app(app).call env
    expect(rs).to eq %w{ first.begin last.begin run last.end first.end }
  end
end

