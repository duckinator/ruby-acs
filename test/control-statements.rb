def _if(cond, true_fn, false_fn = ->{nil})
  cond && true_fn.call || false_fn.call
end

_if(true, | | puts 'true!', | | puts 'false!')

def _case(obj, hsh)
  hsh.each do |k, v|
    ret = _if(k === obj, | | v.call)

    # Bullshit hack because I couldn't get _if() to play nice with returns.
    # Wat @ having to wrap `return ret` in parenthesis.
    ret && (return ret)
  end

  nil
end

p _case(1,
  String  => | | "successfully broke the universe!",
  Numeric => | | "exactly what was expected!",
  Float   => | | "wait, what?",
)
