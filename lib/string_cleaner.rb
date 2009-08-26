# encoding: UTF-8
module String::Cleaner

  # convert invalid UTF-8 strings from ISO-8859-15 to UTF-8 to fix them
  # recognize euro char from both ISO 8859-15 and Windows-1252
  # replace \r\n and \r with \n normalizing end of lines
  # replace control characters and other invisible chars by spaces
  def clean
    utf8 = self.dup
    if utf8.respond_to?(:force_encoding)

      # for Ruby 1.9+
      utf8.force_encoding("UTF-8")
      unless utf8.valid_encoding? # if invalid UTF-8
        utf8 = utf8.force_encoding("ISO8859-15")
        utf8.encode!("UTF-8", :invalid => :replace, :undef => :replace, :replace => "")
        utf8.gsub!("\xC2\x80", "€") # special case for euro sign from Windows-1252
        utf8.force_encoding("UTF-8")
      end
      
      # normalize end of lines
      utf8.gsub!(/\r\n/u, "\n")
      utf8.gsub!(/\r/u, "\n")
      
      # normalize invisible chars
      utf8 = (utf8 << " ").split(/\n/u).each{|line|
        line.gsub!(/[\s\p{C}]/u, " ")
      }.join("\n").chop!
      utf8.force_encoding("UTF-8")
    else

      # for Ruby 1.8.6, use iconv
      require "iconv"
      utf8 << " "
      utf8 = begin
        Iconv.new("UTF-8", "UTF-8").iconv(utf8)
      rescue
        utf8.gsub!(/\x80/n, "\xA4")
        utf8 = Iconv.new("UTF-8//IGNORE", "ISO8859-15").iconv(utf8)
      end

      # normalize end of lines
      utf8.gsub!(/\r\n/n, "\n")
      utf8.gsub!(/\r/n, "\n")
      
      # normalize invisible chars using oniguruma
      require "oniguruma"
      utf8 = utf8.split(/\n/n).collect{|line|
        Oniguruma::ORegexp.new("[\\s\\p{C}]", {:encoding => Oniguruma::ENCODING_UTF8}).gsub(line, " ")
      }.join("\n").chop!
    end
    utf8
    replace(utf8)
  end

end
class String
  include String::Cleaner
end