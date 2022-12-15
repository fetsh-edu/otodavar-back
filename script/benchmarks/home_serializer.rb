# frozen_string_literal: true

require_relative "../../config/environment"

# Any benchmarking setup goes here...



Benchmark.ips do |x|
  x.report("Panko serialize") { user = User.find(8); HomeSerializer.new(context: { cache: SerializerCache.for(user) }).serialize_to_json(user) }
  # x.report("Cached hand rolled") { user = User.find(8); HomeSerializer2.new(user).serialize }
  x.compare!
end
