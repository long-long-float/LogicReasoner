extract_prime_exprs = (ast) ->
  if typeof ast == 'string'
    return ast

  ret = []
  for key, node of ast
    continue if key == 'ope'
    ret.push extract_prime_exprs(node)

  return ret

reason_expr = (expr, env) ->
  if expr.ope
    left  = if expr.left then reason_expr(expr.left, env)
    right = reason_expr(expr.right, env)

    switch expr.ope
      when '<->'
        return left == right
      when '->'
        return !(left && !right)
      when '^'
        return left && right
      when 'v'
        return left || right
      when '~'
        return !right

  else
    env[expr]

reason = (expr, prime_exprs) ->
  for count in [0...Math.pow(2, prime_exprs.length)]
    vals = []
    for i in [0...prime_exprs.length]
      vals.push ((count >> i) & 1) == 1
    env = _.object(prime_exprs, vals)
    unless reason_expr(expr, env)
      return { result: false, values: env }

  return { result: true }

$ ->
  $('#check_button').click ->
    try
      ast = PEG.parse($('#proposition').val())
    catch e
      $('#result').text(e.toString()).css(color: '#f00')

    prime_exprs = _.uniq(_.flatten(extract_prime_exprs(ast)))
    result = reason(ast, prime_exprs)

    $('#result').css(color: '#000')
    if result.result
      $('#result').text('正しいです')
    else
      values = _.map(result.values, (v, k) -> "#{k}: #{v}").join(', ')
      $('#result').text("正しくないです #{values}")
