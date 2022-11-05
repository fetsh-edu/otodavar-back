require 'jwt'
require 'net/http'
class JwtVerifier < ApplicationService

  def initialize(jwt)
    @jwt = jwt
  end

  attr_reader :jwt

  def call
    opts = {
      algorithm: 'RS256',
      jwks: ->(options) do
        @cached_keys = nil if options[:invalidate] # need to reload the keys
        @cached_keys ||= { keys: parse_jwks("https://www.googleapis.com/oauth2/v3/certs")[:keys] }
      end
    }
    JWT.decode(jwt, nil, true, opts)
  end

  private

  def parse_jwks(jwks_uri)
    res = Net::HTTP.get_response(URI(jwks_uri))
    JSON.parse(res.body, symbolize_names: true) # jwt expects symbols for all Hash keys
  end
end
