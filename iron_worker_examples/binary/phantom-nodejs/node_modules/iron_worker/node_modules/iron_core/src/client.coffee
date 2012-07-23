require('pkginfo')(module)
version = @version

_ = require('underscore')
fs = require('fs')
request = require('request')

class Client
  MAX_RETRIES = 5

  constructor: (company, product, options = {}, default_options = {}, extra_options_list = []) ->
    core_default_options =
      user_agent: @version()

    @options_list = ['scheme', 'host', 'port', 'user_agent'].concat(extra_options_list)

    @options = {}

    @load_from_hash('params', options)
    @load_from_config(company, product, options.config_file)
    @load_from_env(company.toUpperCase() + '_' + product.toUpperCase())
    @load_from_env(company.toUpperCase())
    @load_from_config(company, product, "./.#{company}.json")
    @load_from_config(company, product, "./#{company}.json")
    @load_from_config(company, product, "~/.#{company}.json")
    @load_from_hash('defaults', default_options)
    @load_from_hash('defaults', core_default_options)

  version: ->
    "iron_core_node-#{version}"

  set_option: (source, name, value) ->
    if (not @options[name]?) and value?
      console.log("Setting #{name} to '#{value}' from #{source}")
      
      @options[name] = value

  load_from_hash: (source, hash) ->
    if hash?
      @set_option(source, option, hash[option]) for option in @options_list

  load_from_env: (prefix) ->
    @set_option('environment_variable', option, process.env[prefix + '_' + option.toUpperCase()]) for option in @options_list

  load_from_config: (company, product, config_file) ->
    if config_file?
      try
        real_config_file = config_file.replace(/^~/, process.env.HOME)

        config = JSON.parse(fs.readFileSync(real_config_file))

        @load_from_hash(config_file, config["#{company}_#{product}"])
        @load_from_hash(config_file, config[company])
        @load_from_hash(config_file, config)

  headers: ->
    {'User-Agent': @options.user_agent}

  url: ->
    "#{@options.scheme}://#{@options.host}:#{@options.port}/"

  request: (request_info, cb, retry = 0) ->
    request_bind = _.bind(@request, @)

    request(request_info, (error, response, body) ->
      if response.statusCode == 200
        cb(error, response, body)
      else
        if response.statusCode == 503 and retry < @MAX_RETRIES
          delay = Math.pow(4, retry) * 100 * Math.random()
          _.delay(request_bind, delay, request_info, cb, retry + 1)
        else
          cb(error, response, body)
    )

  get: (method, params, cb) ->
    request_info =
      method: 'GET'
      uri: @url() + method
      headers: @headers()
      qs: params

    @request(request_info, cb)

  post: (method, params, cb) ->
    request_info =
      method: 'POST'
      uri: @url() + method
      headers: @headers()
      json: params

    @request(request_info, cb)

  put: (method, params, cb) ->
    request_info =
      method: 'PUT'
      uri: @url() + method
      headers: @headers()
      json: params

    @request(request_info, cb)

  delete: (method, params, cb) ->
    request_info =
      method: 'DELETE'
      uri: @url() + method
      headers: @headers()
      qs: params

    @request(request_info, cb)

  parse_response: (error, response, body, cb) ->
    if response.statusCode == 200
      cb(null, body)
    else
      cb(new Error(body), null)

module.exports.Client = Client
