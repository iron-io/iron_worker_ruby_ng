puts({
       :payload => payload,
       :params => params,
       :iron_task_id => iron_task_id,
       :indifferent_access => params[:a].equal?(params["a"])
     }.to_json)
