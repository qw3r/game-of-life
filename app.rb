require 'rubygems'
require 'bundler/setup'

Bundler.setup :default, (ENV['RACK_ENV'] || 'development')

require './app/gol'

