require File.expand_path("../../helpers", __FILE__)

class TestParserEscapes < Test::Unit::TestCase

  tests = {
    /a\ac/    => [1, :escape,   :bell,              EscapeSequence::Bell],
    /a\ec/    => [1, :escape,   :escape,            EscapeSequence::AsciiEscape],
    /a\fc/    => [1, :escape,   :form_feed,         EscapeSequence::FormFeed],
    /a\nc/    => [1, :escape,   :newline,           EscapeSequence::Newline],
    /a\rc/    => [1, :escape,   :carriage,          EscapeSequence::Return],
    /a\tc/    => [1, :escape,   :tab,               EscapeSequence::Tab],
    /a\vc/    => [1, :escape,   :vertical_tab,      EscapeSequence::VerticalTab],

    # special cases
    /a\bc/    => [1, :anchor,   :word_boundary,     Anchor::WordBoundary],
    /a\sc/    => [1, :type,     :space,             CharacterType::Space],

    # meta character escapes
    /a\.c/    => [1, :escape,   :dot,               EscapeSequence::Literal],
    /a\?c/    => [1, :escape,   :zero_or_one,       EscapeSequence::Literal],
    /a\*c/    => [1, :escape,   :zero_or_more,      EscapeSequence::Literal],
    /a\+c/    => [1, :escape,   :one_or_more,       EscapeSequence::Literal],
    /a\|c/    => [1, :escape,   :alternation,       EscapeSequence::Literal],
    /a\(c/    => [1, :escape,   :group_open,        EscapeSequence::Literal],
    /a\)c/    => [1, :escape,   :group_close,       EscapeSequence::Literal],
    /a\{c/    => [1, :escape,   :interval_open,     EscapeSequence::Literal],
    /a\}c/    => [1, :escape,   :interval_close,    EscapeSequence::Literal],
  }

  count = 0
  tests.each do |pattern, test|
    define_method "test_parse_escape_#{test[2]}_#{count+=1}" do
      root = RP.parse(pattern, 'ruby/1.9')
      exp  = root.expressions[test[0]]

      assert( exp.is_a?( test[3] ),
             "Expected #{test[3]}, but got #{exp.class.name}")

      assert_equal( test[1], exp.type )
      assert_equal( test[2], exp.token )
    end
  end

  def test_parse_escape_control_sequence_lower
    root = RP.parse(/a\\\c2b/)

    assert_equal( EscapeSequence::Control,  root[2].class )
    assert_equal( '\\c2',                   root[2].text )
  end

  def test_parse_escape_control_sequence_upper
    root = RP.parse(/\d\\\C-C\w/)

    assert_equal( EscapeSequence::Control,  root[2].class )
    assert_equal( '\\C-C',                  root[2].text )
  end

  def test_parse_escape_meta_sequence
    root = RP.parse(/\Z\\\M-Z/n)

    assert_equal( EscapeSequence::Meta,  root[2].class )
    assert_equal( '\\M-Z',               root[2].text )
  end

  def test_parse_escape_meta_control_sequence
    root = RP.parse(/\A\\\M-\C-X/n)

    assert_equal( EscapeSequence::MetaControl,  root[2].class )
    assert_equal( '\\M-\\C-X',                  root[2].text )
  end

end
