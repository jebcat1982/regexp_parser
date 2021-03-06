require File.expand_path("../../helpers", __FILE__)

class ScannerConditionals < Test::Unit::TestCase

  # Basic conditional scan token tests
  tests = {
    /(?(1)T|F)/           => [0, :conditional,  :open,              '(?',   0,  2],
    /(?(2)T|F)/           => [1, :conditional,  :condition_open,    '(',    2,  3],
    /(?(3)T|F)/           => [2, :conditional,  :condition,         '3',    3,  4],
    /(?(4)T|F)/           => [3, :conditional,  :condition_close,   ')',    4,  5],
    /(?(5)T|F)/           => [4, :literal,      :literal,           'T',    5,  6],
    /(?(6)T|F)/           => [5, :conditional,  :separator,         '|',    6,  7],
    /(?(7)T|F)/           => [6, :literal,      :literal,           'F',    7,  8],
    /(?(8)T|F)/           => [7, :conditional,  :close,             ')',    8,  9],

    /(?(1)TRUE)/          => [5, :conditional,  :close,             ')',    9, 10],

    /(?(1)TRUE|)/         => [5, :conditional,  :separator,         '|',    9, 10],
    /(?(2)TRUE|)/         => [6, :conditional,  :close,             ')',   10, 11],

    /(?<N>A)(?(<N>)T|F)/  => [5, :conditional,  :condition,         '<N>', 10, 13],
    /(?'N'A)(?('N')T|F)/  => [5, :conditional,  :condition,         "'N'", 10, 13],
  }

  count = 0
  tests.each do |pattern, test|
    define_method "test_scan_#{test[1]}_#{test[2]}_#{count+=1}" do

      tokens = RS.scan(pattern)
      token = tokens[test[0]]
      assert_equal( test[1,5], token )

    end
  end

  def test_scan_conditional_nested
    regexp = /(a(b(c)))(?(1)(?(2)d|(?(3)e|f))|(?(2)(?(1)g|h)))/
    tokens = RS.scan(regexp)

    [ [ 0, :group,        :capture,         '(',   0,  1],
      [ 1, :literal,      :literal,         'a',   1,  2],
      [ 2, :group,        :capture,         '(',   2,  3],
      [ 3, :literal,      :literal,         'b',   3,  4],
      [ 4, :group,        :capture,         '(',   4,  5],
      [ 5, :literal,      :literal,         'c',   5,  6],
      [ 6, :group,        :close,           ')',   6,  7],
      [ 7, :group,        :close,           ')',   7,  8],
      [ 8, :group,        :close,           ')',   8,  9],
      [ 9, :conditional,  :open,            '(?',  9, 11],
      [10, :conditional,  :condition_open,  '(',  11, 12],
      [11, :conditional,  :condition,       '1',  12, 13],
      [12, :conditional,  :condition_close, ')',  13, 14],
      [13, :conditional,  :open,            '(?', 14, 16],
      [14, :conditional,  :condition_open,  '(',  16, 17],
      [15, :conditional,  :condition,       '2',  17, 18],
      [16, :conditional,  :condition_close, ')',  18, 19],
      [17, :literal,      :literal,         'd',  19, 20],
      [18, :conditional,  :separator,       '|',  20, 21],
      [19, :conditional,  :open,            '(?', 21, 23],
      [20, :conditional,  :condition_open,  '(',  23, 24],
      [21, :conditional,  :condition,       '3',  24, 25],
      [22, :conditional,  :condition_close, ')',  25, 26],
      [23, :literal,      :literal,         'e',  26, 27],
      [24, :conditional,  :separator,       '|',  27, 28],
      [25, :literal,      :literal,         'f',  28, 29],
      [26, :conditional,  :close,           ')',  29, 30],
      [27, :conditional,  :close,           ')',  30, 31],
      [28, :conditional,  :separator,       '|',  31, 32],
      [29, :conditional,  :open,            '(?', 32, 34],
      [30, :conditional,  :condition_open,  '(',  34, 35],
      [31, :conditional,  :condition,       '2',  35, 36],
      [32, :conditional,  :condition_close, ')',  36, 37],
      [33, :conditional,  :open,            '(?', 37, 39],
      [34, :conditional,  :condition_open,  '(',  39, 40],
      [35, :conditional,  :condition,       '1',  40, 41],
      [36, :conditional,  :condition_close, ')',  41, 42],
      [37, :literal,      :literal,         'g',  42, 43],
      [38, :conditional,  :separator,       '|',  43, 44],
      [39, :literal,      :literal,         'h',  44, 45],
      [40, :conditional,  :close,           ')',  45, 46],
      [41, :conditional,  :close,           ')',  46, 47],
      [42, :conditional,  :close,           ')',  47, 48]
    ].each do |test|
      assert_equal( test[1,5], tokens[test[0]] )
    end
  end

  def test_scan_conditional_nested_groups
    regexp = /((a)|(b)|((?(2)(c(d|e)+)?|(?(3)f|(?(4)(g|(h)(i)))))))/
    tokens = RS.scan(regexp)

    [ [ 0, :group,        :capture,         '(',   0,  1],
      [ 1, :group,        :capture,         '(',   1,  2],
      [ 2, :literal,      :literal,         'a',   2,  3],
      [ 3, :group,        :close,           ')',   3,  4],
      [ 4, :meta,         :alternation,     '|',   4,  5],
      [ 5, :group,        :capture,         '(',   5,  6],
      [ 6, :literal,      :literal,         'b',   6,  7],
      [ 7, :group,        :close,           ')',   7,  8],
      [ 8, :meta,         :alternation,     '|',   8,  9],
      [ 9, :group,        :capture,         '(',   9, 10],
      [10, :conditional,  :open,            '(?', 10, 12],
      [11, :conditional,  :condition_open,  '(',  12, 13],
      [12, :conditional,  :condition,       '2',  13, 14],
      [13, :conditional,  :condition_close, ')',  14, 15],
      [14, :group,        :capture,         '(',  15, 16],
      [15, :literal,      :literal,         'c',  16, 17],
      [16, :group,        :capture,         '(',  17, 18],
      [17, :literal,      :literal,         'd',  18, 19],
      [18, :meta,         :alternation,     '|',  19, 20],
      [19, :literal,      :literal,         'e',  20, 21],
      [20, :group,        :close,           ')',  21, 22],
      [21, :quantifier,   :one_or_more,     '+',  22, 23],
      [22, :group,        :close,           ')',  23, 24],
      [23, :quantifier,   :zero_or_one,     '?',  24, 25],
      [24, :conditional,  :separator,       '|',  25, 26],
      [25, :conditional,  :open,            '(?', 26, 28],
      [26, :conditional,  :condition_open,  '(',  28, 29],
      [27, :conditional,  :condition,       '3',  29, 30],
      [28, :conditional,  :condition_close, ')',  30, 31],
      [29, :literal,      :literal,         'f',  31, 32],
      [30, :conditional,  :separator,       '|',  32, 33],
      [31, :conditional,  :open,            '(?', 33, 35],
      [32, :conditional,  :condition_open,  '(',  35, 36],
      [33, :conditional,  :condition,       '4',  36, 37],
      [34, :conditional,  :condition_close, ')',  37, 38],
      [35, :group,        :capture,         '(',  38, 39],
      [36, :literal,      :literal,         'g',  39, 40],
      [37, :meta,         :alternation,     '|',  40, 41],
      [38, :group,        :capture,         '(',  41, 42],
      [39, :literal,      :literal,         'h',  42, 43],
      [40, :group,        :close,           ')',  43, 44],
      [41, :group,        :capture,         '(',  44, 45],
      [42, :literal,      :literal,         'i',  45, 46],
      [43, :group,        :close,           ')',  46, 47],
      [44, :group,        :close,           ')',  47, 48],
      [45, :conditional,  :close,           ')',  48, 49],
      [46, :conditional,  :close,           ')',  49, 50],
      [47, :conditional,  :close,           ')',  50, 51],
      [48, :group,        :close,           ')',  51, 52],
      [49, :group,        :close,           ')',  52, 53]
    ].each do |test|
      assert_equal( test[1,5], tokens[test[0]] )
    end
  end

  def test_scan_conditional_nested_alternation
    regexp = /(a)(?(1)(b|c|d)|(e|f|g))(h)(?(2)(i|j|k)|(l|m|n))|o|p/
    tokens = RS.scan(regexp)

    [9, 11, 17, 19, 32, 34, 40, 42, 46, 48].each do |token|
      assert_equal(:meta,         tokens[token][0])
      assert_equal(:alternation,  tokens[token][1])
      assert_equal('|',           tokens[token][2])
      assert_equal(1,             tokens[token][4] - tokens[token][3])
    end

    [14, 37].each do |token|
      assert_equal(:conditional,  tokens[token][0])
      assert_equal(:separator,    tokens[token][1])
      assert_equal('|',           tokens[token][2])
      assert_equal(1,             tokens[token][4] - tokens[token][3])
    end
  end

end
