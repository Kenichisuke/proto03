# coding: utf-8
require 'rails_helper'

describe OrderDecorator do
  let(:order) { Order.new.extend OrderDecorator }
  subject { order }
  it { should be_a Order }
end
