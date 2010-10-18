# encoding: UTF-8
require File.dirname(__FILE__) + "/spec_helper"

describe String::Cleaner do
  if "".respond_to?(:force_encoding)
    # specs for Ruby 1.9+
    describe "with all 8-bit characters" do
      before :all do
        @input = "".force_encoding("ISO8859-15")
        (0..255).each{|i| @input << i.chr}
        @input.force_encoding("UTF-8")
        @output = @input.clean
      end
      it "should output a valid UTF-8 string" do
        @output.encoding.name.should == "UTF-8"
        @output.should be_valid_encoding
      end
      it "should wipe out the control characters" do
        @output.should == "          \n  \n                   !\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ €                                ¡¢£€¥Š§š©ª«¬ ®¯°±²³Žµ¶·ž¹º»ŒœŸ¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ"
      end
    end
    it "should convert all type of spaces to normal spaces" do
      input = [
                (0x0009..0x000D).to_a, # White_Space # Cc   [5] <control-0009>..<control-000D>
                0x0020,                # White_Space # Zs       SPACE
                0x0085,                # White_Space # Cc       <control-0085>
                0x00A0,                # White_Space # Zs       NO-BREAK SPACE
                0x1680,                # White_Space # Zs       OGHAM SPACE MARK
                0x180E,                # White_Space # Zs       MONGOLIAN VOWEL SEPARATOR
                (0x2000..0x200A).to_a, # White_Space # Zs  [11] EN QUAD..HAIR SPACE
                0x2028,                # White_Space # Zl       LINE SEPARATOR
                0x2029,                # White_Space # Zp       PARAGRAPH SEPARATOR
                0x202F,                # White_Space # Zs       NARROW NO-BREAK SPACE
                0x205F,                # White_Space # Zs       MEDIUM MATHEMATICAL SPACE
                0x3000,                # White_Space # Zs       IDEOGRAPHIC SPACE
              ].flatten.collect{ |e| [e].pack 'U*' }
      input.join.clean.should == " \n  \n                     "
    end
    describe "with invalid UTF-8 sequence" do
      before :all do
        @input = "\210\004"
        @output = @input.clean
      end
      it "should output a valid UTF-8 string" do
        @output.encoding.name.should == "UTF-8"
        @output.should be_valid_encoding
      end
      it "should replace invisible chars by space" do
        @output.should == "  "
      end
    end
    describe "with mixed valid and invalid characters" do
      before :all do
        @input = "a?^?\xddf"
        @output = @input.clean
      end
      it "should output a valid UTF-8 string" do
        @output.encoding.name.should == "UTF-8"
        @output.should be_valid_encoding
      end
      it "should keep the valid characters" do
        @output.should == "a?^?Ýf"
      end
    end
    describe "with already valid characters" do
      before :all do
        @input = "\n\t\r\r\n\v\n"
        @output = @input.clean
      end
      it "should output a valid UTF-8 string" do
        @output.encoding.name.should == "UTF-8"
        @output.should be_valid_encoding
      end
      it "should replace invisible chars by space" do
        @output.should == "\n \n\n \n"
      end
    end
    describe "with watermarked text" do
      before :all do
        @input = "Here is \357\273\277a block \357\273\277of text \357\273\277inside of which a number will be hidden!"
        @output = @input.clean
      end
      it "should output a valid UTF-8 string" do
        @output.encoding.name.should == "UTF-8"
        @output.should be_valid_encoding
      end
      it "should replace invisible chars by space" do
        @output.should == "Here is  a block  of text  inside of which a number will be hidden!"
      end
    end
    describe "with unusual valid spaces" do
      before :all do
        @input = []
        @input << "\u0020" # SPACE
        @input << "\u00A0" # NO-BREAK SPACE
        @input << "\u2000" # EN QUAD
        @input << "\u2001" # EM QUAD
        @input << "\u2002" # EN SPACE
        @input << "\u2003" # EM SPACE
        @input << "\u2004" # THREE-PER-EM SPACE
        @input << "\u2005" # FOUR-PER-EM SPACE
        @input << "\u2006" # SIX-PER-EM SPACE
        @input << "\u2007" # FIGURE SPACE
        @input << "\u2008" # PUNCTUATION SPACE
        @input << "\u2009" # THIN SPACE
        @input << "\u200A" # HAIR SPACE
        @input << "\u200B" # ZERO WIDTH SPACE
        @input << "\u202F" # NARROW NO-BREAK SPACE
        @input << "\u205F" # MEDIUM MATHEMATICAL SPACE
        @input << "\u3000" # IDEOGRAPHIC SPACE
        @input << "\uFEFF" # ZERO WIDTH NO-BREAK SPACE
        @output = @input.join.clean
      end
      it "should output a valid UTF-8 string" do
        @output.encoding.name.should == "UTF-8"
        @output.should be_valid_encoding
      end
      it "should replace invisible chars by space" do
        @output.should == " "*@input.size
      end
    end
    describe "with euro sign from both ISO 8859-15 or Windows-1252" do
      before :all do
        @input = "\x80\xA4"
        @output = @input.clean
      end
      it "should output a valid UTF-8 string" do
        @output.encoding.name.should == "UTF-8"
        @output.should be_valid_encoding
      end
      it "should replace invisible chars by space" do
        @output.should == "€€"
      end
    end
  else
    # specs for Ruby 1.8.6
    describe "with all 8-bit characters" do
      before :all do
        @input = ""
        (0..255).each{|i| @input << i.chr}
        @output = @input.clean
      end
      it "should wipe out the control characters" do
        @output.should == "          \n  \n                   !\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ €                                ¡¢£€¥Š§š©ª«¬ ®¯°±²³Žµ¶·ž¹º»ŒœŸ¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ"
      end
    end
    describe "with invalid UTF-8 sequence" do
      before :all do
        @input = "\210\004"
        @output = @input.clean
      end
      it "should replace invisible chars by space" do
        @output.should == "  "
      end
    end
    describe "with mixed valid and invalid characters" do
      before :all do
        @input = "a?^?\xddf"
        @output = @input.clean
      end
      it "should keep the valid characters" do
        @output.should == "a?^?Ýf"
      end
    end
    describe "with already valid characters" do
      before :all do
        @input = "\n\t\r\r\n\v\n"
        @output = @input.clean
      end
      it "should replace invisible chars by space" do
        @output.should == "\n \n\n \n"
      end
    end
    describe "with watermarked text" do
      before :all do
        @input = "Here is \357\273\277a block \357\273\277of text \357\273\277inside of which a number will be hidden!"
        @output = @input.clean
      end
      it "should replace invisible chars by space" do
        @output.should == "Here is  a block  of text  inside of which a number will be hidden!"
      end
    end
    describe "with unusual valid spaces" do
      before :all do
        @input = []
        # "\uXXXX" doesn't exists yet on Ruby 1.8.6
        @input << " "            # SPACE
        @input << "\xC2\xA0"     # NO-BREAK SPACE
        @input << "\xE2\x80\x80" # EN QUAD
        @input << "\xE2\x80\x81" # EM QUAD
        @input << "\xE2\x80\x82" # EN SPACE
        @input << "\xE2\x80\x83" # EM SPACE
        @input << "\xE2\x80\x84" # THREE-PER-EM SPACE
        @input << "\xE2\x80\x85" # FOUR-PER-EM SPACE
        @input << "\xE2\x80\x86" # SIX-PER-EM SPACE
        @input << "\xE2\x80\x87" # FIGURE SPACE
        @input << "\xE2\x80\x88" # PUNCTUATION SPACE
        @input << "\xE2\x80\x89" # THIN SPACE
        @input << "\xE2\x80\x8A" # HAIR SPACE
        @input << "\xE2\x80\x8B" # ZERO WIDTH SPACE
        @input << "\xE2\x80\xAF" # NARROW NO-BREAK SPACE
        @input << "\xE2\x81\x9F" # MEDIUM MATHEMATICAL SPACE
        @input << "\xE3\x80\x80" # IDEOGRAPHIC SPACE
        @input << "\xEF\xBB\xBF" # ZERO WIDTH NO-BREAK SPACE
        @output = @input.join.clean
      end
      it "should replace invisible chars by space" do
        @output.should == " "*@input.size
      end
    end
    describe "with euro sign from both ISO 8859-15 or Windows-1252" do
      before :all do
        @input = "\x80\xA4"
        @output = @input.clean
      end
      it "should replace invisible chars by space" do
        @output.should == "€€"
      end
    end
  end
  describe "#trim(chars = \"\")" do
    it "should use #strip when used without params" do
      string, expected = "", mock
      string.stub(:strip).and_return expected
      string.trim.should be expected
    end
    it "should remove multiple characters at once from beginning and end" do
      prefix, suffix = " rhuif dww f f", "dqz  qafdédsj iowe fcms. qpo asttt t dtt"
      to_remove = "acdeéfhijmopqrstuwz "
      "#{prefix}d#{suffix}".trim(to_remove).should eql "."
      "#{prefix}D#{suffix}".trim(to_remove).should eql "Ddqz  qafdédsj iowe fcms."
    end
  end
  describe "#fix_endlines" do
    it "should convert windows endlines" do
      "this is a\r\ntest\r\n".fix_endlines.should eql "this is a\ntest\n"
    end
    it "should convert old mac endlines" do
      "this is a\rtest\r".fix_endlines.should eql "this is a\ntest\n"
    end
    it "should not modify proper linux endlines" do
      "this is a\ntest\n".fix_endlines.should eql "this is a\ntest\n"
    end
    it "should convert mixed endlines" do
      "this is a\n\rtest\r\n".fix_endlines.should eql "this is a\n\ntest\n"
    end
  end
  describe "#to_permalink(separator=\"-\")" do
    it "should create nice permalink for string with many accents" do
      crazy = "  ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöøùúûüý - Hello world, I'm a crazy string!! "
      crazy.to_permalink.should == "aaaaaaceeeeiiiidnoooooxouuuuyaaaaaaceeeeiiiinoooooouuuuy-hello-world-i-m-a-crazy-string"
    end
    it "should create nice permalink even for evil string" do
      evil = (128..255).inject(""){ |acc, b| acc += ("%c" % b) }
      evil.to_permalink.should == "euros-cents-pounds-euros-yens-section-copyright-registered-trademark-degrees-approx-23-micro-paragraph-10-1-4-1-2-3-4-aaaaaaaeceeeeiiiidnoooooxouuuuythssaaaaaaaeceeeeiiiidnooooo-ouuuuythy"
    end
    it "should remove endlines too" do
      "this\nis\ta\ntest".to_permalink("_").should eql "this_is_a_test"
    end
  end
  describe "#nl2br" do
    it "should convert \n to <br/>\n" do
      "this\nis\ta\ntest\r".nl2br.should eql "this<br/>\nis\ta<br/>\ntest\r"
    end
  end
  describe "#to_nicer_sym" do
    it "should convert \"Select or Other\" to :select_or_other" do
      "Select or Other".to_nicer_sym.should be :select_or_other
    end
  end
end