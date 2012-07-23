require('pkginfo')(module)
version = @version

_ = require('underscore')

iron_core = require('iron_core');

class APIClient extends iron_core.Client
  AWS_US_EAST_HOST: 'worker-aws-us-east-1.iron.io'

  constructor: (options) ->
    default_options =
      scheme: 'https',
      host: @AWS_US_EAST_HOST,
      port: 443,
      api_version: 2,

    super('iron', 'worker', options, default_options, ['project_id', 'token', 'api_version'])

  version: ->
    "iron_worker_node-#{version} (#{super()})"

  url: ->
    super() + @options.api_version.toString() + '/'

  headers: ->
    _.extend({}, super(), {'Authorization': "OAuth #{@options.token}"})

  tasks_create: (code_name, payload, options, cb) ->
    parse_response_bind = _.bind(@parse_response, @)

    @post("projects/#{@options.project_id}/tasks", {'tasks': [_.extend({'code_name': code_name, 'payload': payload}, options)]}, (error, response, body) ->
      parse_response_bind(error, response, body, cb)
    )

module.exports.APIClient = APIClient
