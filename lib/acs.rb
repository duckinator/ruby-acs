require File.join(File.dirname(__FILE__), 'acs', 'version')

require 'ripper'

class ACS
  attr_accessor :code, :file, :debug

  def initialize(file)
    @file  = file
    @code  = File.open(file).read
    @lex   = nil
    @debug = false
  end

  def run!
    # Before we run the code, we store a reference to the class in a local
    # variable, then remove it. This makes ACS entirely transparent aside from
    # pulling in Ripper.
    acs = ACS
    Object.class_eval { remove_const :ACS }

    eval(code, TOPLEVEL_BINDING, file)

    # Restore the ACS class.
    Object.const_set(:ACS, acs)
  end

  def process!
    old = ''
    new = code

    debug_print

    until old == new
      old = new
      process_once!
      new = code

      debug_print
    end

    code
  end

  def process_once!
    @lex = get_lex_data

    index_of_each =
      lambda do |name, value = nil|
        @lex.each_with_index.find_all do |x, i|
          x[1] == name && (value.nil? || x[2] == value)
        end.map(&:last)
      end

    defs    = index_of_each.(:on_kw, 'def')
    lparens = index_of_each.(:on_lparen)
    commas  = index_of_each.(:on_comma)
    bars    = index_of_each.(:on_op, '|')
    
    # Remove all left parenthesis that are part of a `def ...(...)`.
    lparens.reject! { |i| defs.include?(i - 2) }

    # Remove all bars that don't immediately follow a left parenthesis or comma.
    bars.select! { |i| lparens.include?(i - 1) || commas.include?(i - 1) }

    # Remove all left parenthesis that don't immediately precede a bar.
    lparens.select! { |i| bars.include?(i + 1) }

    return if bars.empty?

    i = bars.first

    start_line, start_column = @lex[i][0]
    start_line -= 1 # We need 0-indexed, not 1-indexed.

    end_line, end_column = find_end(i)

    parts = @code.split("\n")
    parts[start_line][start_column] = "lambda { #{parts[start_line][start_column]}"
    parts[end_line][end_column] = "#{parts[end_line][end_column]} }"

    @code = parts.join("\n")
  end

  def find_end(start)
    plevel = 0
    blevel = 0
    between_bars = false

    ret = nil

    start.upto(@lex.length - 1).select do |i|
      part = @lex[i]

      if part[1] == :on_lparen
        plevel += 1
      elsif part[1] == :on_rparen
        plevel -= 1
        ret = part[0] if plevel <= 0
        break
      elsif part[1] == :on_op && part[2] == '|'
        between_bars = !between_bars
      elsif part[1] == :on_lbracket
        blevel += 1
      elsif part[1] == :on_rbracket
        blevel -= 1
      elsif part[1] == :on_comma && !between_bars &&
            plevel <= 0 && blevel <= 0
        ret = part[0]
        break
      end
    end

    line, column = ret

    line -= 1 # We need 0-indexed, not 1-indexed.
    column += 'lambda { '.length - 1

    [line, column]
  end

  def get_lex_data
    lex  = Ripper.lex(@code)

    # Remove spaces so ordering is more predictable.
    lex.reject! { |x| [:on_sp, :on_ignored_nl].include?(x[1]) }

    lex
  end

  private
  def debug_print
    return unless debug

    @iteration ||= 0
    @iteration += 1
    puts "---- Iteration #{@iteration} ----"
    puts code
    puts "----/Iteration #{@iteration} ----"
  end

  class << self
    # ACS.i_am_an_amoeba effectively pulls the Ripper class into ACS::Ripper,
    # then it removes all files related to Ripper from $LOADED_FEATURES.
    private
    def i_am_an_amoeba
      self.const_set(:Ripper, ::Ripper)
      Object.class_eval { remove_const :Ripper }

      $LOADED_FEATURES.reject! { |filename| filename =~ %r[/ripper(/|\.(rb|so))] }
    end
  end

  i_am_an_amoeba
end
