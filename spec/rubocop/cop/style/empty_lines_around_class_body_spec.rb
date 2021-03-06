# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyLinesAroundClassBody, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is no_empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_empty_lines' } }

    it 'registers an offense for class body starting with a blank' do
      inspect_source(cop,
                     ['class SomeClass',
                      '',
                      '  do_something',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at class body beginning.'])
    end

    it 'autocorrects class body containing only a blank' do
      corrected = autocorrect_source(cop,
                                     ['class SomeClass',
                                      '',
                                      'end'])
      expect(corrected).to eq ['class SomeClass',
                               'end'].join("\n")
    end

    it 'registers an offense for class body ending with a blank' do
      inspect_source(cop,
                     ['class SomeClass',
                      '  do_something',
                      '',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at class body end.'])
    end

    it 'registers an offense for singleton class body starting with a blank' do
      inspect_source(cop,
                     ['class << self',
                      '',
                      '  do_something',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at class body beginning.'])
    end

    it 'autocorrects singleton class body containing only a blank' do
      corrected = autocorrect_source(cop,
                                     ['class << self',
                                      '',
                                      'end'])
      expect(corrected).to eq ['class << self',
                               'end'].join("\n")
    end

    it 'registers an offense for singleton class body ending with a blank' do
      inspect_source(cop,
                     ['class << self',
                      '  do_something',
                      '',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at class body end.'])
    end
  end

  context 'when EnforcedStyle is empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines' } }

    it 'registers an offense for class body not starting or ending with a ' \
       'blank' do
      inspect_source(cop,
                     ['class SomeClass',
                      '  do_something',
                      'end'])
      expect(cop.messages).to eq(['Empty line missing at class body beginning.',
                                  'Empty line missing at class body end.'])
    end

    it 'ignores classes with an empty body' do
      source = "class SomeClass\nend"
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(source)
    end

    it 'autocorrects beginning and end' do
      new_source = autocorrect_source(cop,
                                      ['class SomeClass',
                                       '  do_something',
                                       'end'])
      expect(new_source).to eq(['class SomeClass',
                                '',
                                '  do_something',
                                '',
                                'end'].join("\n"))
    end

    it 'registers an offense for singleton class body not starting or ending ' \
       'with a blank' do
      inspect_source(cop,
                     ['class << self',
                      '  do_something',
                      'end'])
      expect(cop.messages).to eq(['Empty line missing at class body beginning.',
                                  'Empty line missing at class body end.'])
    end

    it 'ignores singleton classes with an empty body' do
      source = "class << self\nend"
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(source)
    end

    it 'autocorrects beginning and end' do
      new_source = autocorrect_source(cop,
                                      ['class << self',
                                       '  do_something',
                                       'end'])
      expect(new_source).to eq(['class << self',
                                '',
                                '  do_something',
                                '',
                                'end'].join("\n"))
    end
  end

  context 'when EnforcedStyle is empty_lines_except_namespace' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines_except_namespace' } }
    let(:extra_begin) { 'Extra empty line detected at class body beginning.' }
    let(:extra_end) { 'Extra empty line detected at class body end.' }
    let(:missing_begin) { 'Empty line missing at class body beginning.' }
    let(:missing_end) { 'Empty line missing at class body end.' }

    context 'when only child is class' do
      it 'requires no empty lines for namespace' do
        inspect_source(cop,
                       ['class Parent < Base',
                        '  class Child',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([])
      end

      it 'registers offence for namespace body starting with a blank' do
        inspect_source(cop,
                       ['class Parent',
                        '',
                        '  class Child',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([extra_begin])
      end

      it 'registers offence for namespace body ending with a blank' do
        inspect_source(cop,
                       ['class Parent',
                        '  class Child',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        '',
                        'end'])
        expect(cop.messages).to eq([extra_end])
      end

      it 'registers offences for namespaced class body not starting '\
          'with a blank' do
        inspect_source(cop,
                       ['class Parent',
                        '  class Child',
                        '    do_something',
                        '',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([missing_begin])
      end

      it 'registers offences for namespaced class body not ending '\
          'with a blank' do
        inspect_source(cop,
                       ['class Parent',
                        '  class Child',
                        '',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([missing_end])
      end

      it 'autocorrects beginning and end' do
        new_source = autocorrect_source(cop,
                                        ['class Parent < Base',
                                         '',
                                         '  class Child',
                                         '    do_something',
                                         '  end',
                                         '',
                                         'end'])
        expect(new_source).to eq(['class Parent < Base',
                                  '  class Child',
                                  '',
                                  '    do_something',
                                  '',
                                  '  end',
                                  'end'].join("\n"))
      end
    end

    context 'when only child is module' do
      it 'requires no empty lines for namespace' do
        inspect_source(cop,
                       ['class Parent',
                        '  module Child',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([])
      end

      it 'registers offence for namespace body starting with a blank' do
        inspect_source(cop,
                       ['class Parent',
                        '',
                        '  module Child',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([extra_begin])
      end

      it 'registers offence for namespace body ending with a blank' do
        inspect_source(cop,
                       ['class Parent',
                        '  module Child',
                        '    do_something',
                        '  end',
                        '',
                        'end'])
        expect(cop.messages).to eq([extra_end])
      end
    end

    context 'when has multiple child classes' do
      it 'requires empty lines for namespace' do
        inspect_source(cop,
                       ['class Parent',
                        '',
                        '  class Mom',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        '  class Dad',
                        '',
                        '  end',
                        '',
                        'end'])
        expect(cop.messages).to eq([])
      end

      it 'registers offences for namespace body starting '\
        'and ending without a blank' do
        inspect_source(cop,
                       ['class Parent',
                        '  class Mom',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        '  class Dad',
                        '',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([missing_begin, missing_end])
      end
    end
  end
end
