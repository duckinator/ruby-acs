def _if(cond, true_fn, false_fn = ->{nil})
  cond && true_fn.call || false_fn.call
end

_if(true, | | puts 'true!', | | puts 'false!')

def _case(obj, hsh)
  hsh.find{|k, v| k === obj}.last.call
end

p _case(1,
  String  => | | "successfully broke the universe!",
  Numeric => | | "exactly what was expected!",
  Float   => | | "wait, what?",
)
