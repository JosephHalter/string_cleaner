require "spec_helper"

RSpec.describe String::Cleaner do
  describe "#clean" do
    describe "with all 8-bit characters" do
      before :all do
        @input = ""
        @input.force_encoding("ISO8859-15") if @input.respond_to?(:force_encoding)
        (0..255).each{|i| @input << i.chr}
        @input.force_encoding("UTF-8") if @input.respond_to?(:force_encoding)
        @output = @input.clean
      end
      if RUBY_VERSION.to_f>1.9
        it "should output a valid UTF-8 string" do
          expect(@output.encoding.name).to eq "UTF-8"
          expect(@output).to be_valid_encoding
        end
      end
      it "should wipe out the control characters" do
        expect(@output).to eq "          \n  \n                   !\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ €                                ¡¢£€¥¦§¨©ª«¬ ®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ"
      end
    end
    describe "with various type of spaces" do
      before do
        @input = [
          (0x0009..0x000D).to_a, # <control-0009>..<control-000D>
          0x0020,                # SPACE
          0x0085,                # <control-0085>
          0x00A0,                # NO-BREAK SPACE
          0x1680,                # OGHAM SPACE MARK
          0x180E,                # MONGOLIAN VOWEL SEPARATOR
          (0x2000..0x200A).to_a, # EN QUAD..HAIR SPACE
          0x2028,                # LINE SEPARATOR
          0x2029,                # PARAGRAPH SEPARATOR
          0x202F,                # NARROW NO-BREAK SPACE
          0x205F,                # MEDIUM MATHEMATICAL SPACE
          0x3000,                # IDEOGRAPHIC SPACE
        ].flatten.collect{ |e| [e].pack 'U*' }
        @output = @input.join.clean
      end
      if RUBY_VERSION.to_f>1.9
        it "should output a valid UTF-8 string" do
          expect(@output.encoding.name).to eq "UTF-8"
          expect(@output).to be_valid_encoding
        end
      end
      it "should replace all spaces to normal spaces" do
        expect(@output.clean).to eq " \n  \n                     "
      end
    end
    describe "with various no-width characters" do
      before do
        @input = [
          0x200B,                # ZERO WIDTH SPACE
          0x200C,                # ZERO WIDTH NON-JOINER
          0x200D,                # ZERO WIDTH JOINER
          0x2060,                # WORD JOINER
          0xFEFF,                # ZERO WIDTH NO-BREAK SPACE
        ].flatten.collect{ |e| [e].pack 'U*' }
        @output = @input.join.clean
      end
      if RUBY_VERSION.to_f>1.9
        it "should output a valid UTF-8 string" do
          expect(@output.encoding.name).to eq "UTF-8"
          expect(@output).to be_valid_encoding
        end
      end
      it "should remove no-width characters" do
        expect(@output).to eq ""
      end
    end
    describe "with invalid UTF-8 sequence" do
      before :all do
        @input = "\210\004"
        @output = @input.clean
      end
      if RUBY_VERSION.to_f>1.9
        it "should output a valid UTF-8 string" do
          expect(@output.encoding.name).to eq "UTF-8"
          expect(@output).to be_valid_encoding
        end
      end
      it "should replace invisible chars by space" do
        expect(@output).to eq "  "
      end
    end
    describe "with mixed valid and invalid characters" do
      before :all do
        @input = "a?^?\xddf"
        @output = @input.clean
      end
      if RUBY_VERSION.to_f>1.9
        it "should output a valid UTF-8 string" do
          expect(@output.encoding.name).to eq "UTF-8"
          expect(@output).to be_valid_encoding
        end
      end
      it "should keep the valid characters" do
        expect(@output).to eq "a?^?Ýf"
      end
    end
    describe "with already valid characters" do
      before :all do
        @input = "\n\t\r\r\n\v\n"
        @output = @input.clean
      end
      if RUBY_VERSION.to_f>1.9
        it "should output a valid UTF-8 string" do
          expect(@output.encoding.name).to eq "UTF-8"
          expect(@output).to be_valid_encoding
        end
      end
      it "should replace invisible chars by space" do
        expect(@output).to eq "\n \n\n \n"
      end
    end
    describe "with watermarked text" do
      before :all do
        @input = "Here is \357\273\277a block \357\273\277of text \357\273\277inside of which a number will be hidden!"
        @output = @input.clean
      end
      if RUBY_VERSION.to_f>1.9
        it "should output a valid UTF-8 string" do
          expect(@output.encoding.name).to eq "UTF-8"
          expect(@output).to be_valid_encoding
        end
      end
      it "should replace invisible chars by space" do
        expect(@output).to eq "Here is a block of text inside of which a number will be hidden!"
      end
    end
    describe "with euro sign from both ISO 8859-15 or Windows-1252" do
      before :all do
        @input = "\x80\xA4"
        @output = @input.clean
      end
      if RUBY_VERSION.to_f>1.9
        it "should output a valid UTF-8 string" do
          expect(@output.encoding.name).to eq "UTF-8"
          expect(@output).to be_valid_encoding
        end
      end
      it "should replace invisible chars by space" do
        expect(@output).to eq "€€"
      end
    end
  end
  describe "#trim(chars = \"\")" do
    it "should use #strip when used without params" do
      string, expected = "", double
      expect(string).to receive(:strip).and_return expected
      expect(string.trim).to be expected
    end
    it "should remove multiple characters at once from beginning and end" do
      prefix, suffix = " rhuif dww f f", "dqz  qafdédsj iowe fcms. qpo asttt t dtt"
      to_remove = "acdeéfhijmopqrstuwz "
      expect("#{prefix}d#{suffix}".trim(to_remove)).to eq "."
      expect("#{prefix}D#{suffix}".trim(to_remove)).to eq "Ddqz  qafdédsj iowe fcms."
    end
  end
  describe "#fix_endlines" do
    it "should convert windows endlines" do
      expect("this is a\r\ntest\r\n".fix_endlines).to eql "this is a\ntest\n"
    end
    it "should convert old mac endlines" do
      expect("this is a\rtest\r".fix_endlines).to eql "this is a\ntest\n"
    end
    it "should not modify proper linux endlines" do
      expect("this is a\ntest\n".fix_endlines).to eql "this is a\ntest\n"
    end
    it "should convert mixed endlines" do
      expect("this is a\n\rtest\r\n".fix_endlines).to eql "this is a\n\ntest\n"
    end
  end
  describe "#to_permalink(separator=\"-\")" do
    it "should create nice permalink for string with many accents" do
      crazy = "  ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöøùúûüý - Hello world, I'm a crazy string!! "
      expect(crazy.to_permalink).to eq "aaaaaaceeeeiiiidnoooooxouuuuyaaaaaaceeeeiiiinoooooouuuuy-hello-world-i-m-a-crazy-string"
    end
    it "should create nice permalink even for evil string" do
      evil = (128..255).inject(""){ |acc, b| acc += ("%c" % b) }
      expect(evil.to_permalink).to eq "euros-cents-pounds-euros-yens-section-copyright-registered-trademark-degrees-approx-23-micro-paragraph-10-1-4-1-2-3-4-aaaaaaaeceeeeiiiidnoooooxouuuuythssaaaaaaaeceeeeiiiidnooooo-ouuuuythy"
    end
    it "should remove endlines too" do
      expect("this\nis\ta\ntest".to_permalink("_")).to eq "this_is_a_test"
    end
  end
  describe "#nl2br" do
    it "should convert \n to <br/>\n" do
      expect("this\nis\ta\ntest\r".nl2br).to eq "this<br/>\nis\ta<br/>\ntest\r"
    end
  end
  describe "#to_nicer_sym" do
    it "should convert \"Select or Other\" to :select_or_other" do
      expect("Select or Other".to_nicer_sym).to be :select_or_other
    end
  end
end
