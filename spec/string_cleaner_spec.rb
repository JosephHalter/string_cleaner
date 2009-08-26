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
end