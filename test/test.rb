#!/usr/bin/env ruby-acs

require 'pp'

def handle(*args)
  args.each do |x|
    x.call('a', 'b') if x.is_a?(Proc)
  end

  pp args
end

def test(a)
  handle a
end

def test2(a, b)
  handle(a, b)
end

def test3(a, b, c)
  handle(a,b, c)
end

lambda { |a, b| p([a, b]) }

test(|a, b| p [a, b])

test ( | a , b | p [ a , b ] )

test2('foobar', |a, b| p [a, b])

test2(|a, b| p [a, b], 'foobar')

test2(|a, b| p [a, b], |c, d| p [c, d])

test3(|a, b| p [a, b], 'foobar', |c, d| p [c, d])

test3(|a, b| p [a, b],
      |c, d| p [c, d],
      |e, f| p [e, f])

