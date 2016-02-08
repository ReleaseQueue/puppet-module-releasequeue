
warning($rq_ip)
host { 'api.releasequeue.com':
    ip  => "$rq_ip",
}
host { 'releasequeue.com':
    ip => "$rq_ip",
}


releasequeue::application { 'app1':
  version        => '1.0',
  username       => $rq_username,
  api_key        => $rq_api_key,
  local_username => $rq_local_username,
}
