api_client = require('./api_client')

class Client
  constructor: (options) ->
    @api = new api_client.APIClient(options)

  tasks_create: (code_name, params, options, cb) ->
    payload = ''
    
    if typeof(params) == 'string'
      payload = params
    else
      payload = JSON.stringify(params)

    @api.tasks_create(code_name, payload, options, (error, body) ->
      if not error?
        cb(error, body.tasks[0])
      else
        cb(error, body)
    )

module.exports.Client = Client
