#--
# Copyright 2006, Thierry Godfroid
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# * The name of the author may not be used to endorse or promote products derived
# 	from this software without specific prior written permission.
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# This module provides all the methods of the ISBN-Tools library.
# Methods have no state but the library reads the file data/ranges.dat
# and fills up the RNG hash when loaded.
	# Supported groups and associated ranges. Data is read from data/ranges.dat
	# (provided in gem) at module load.
class Tools
  # Check that the value is a valid ISBN-10 number. Returns true if it is, false otherwise.
  # The method will check that the number is exactly 10 digits long and that the tenth digit is
  # the correct checksum for the number.
  def is_valid_isbn10?(isbn_)
    isbn = cleanup(isbn_)
    return false if isbn.nil? or isbn.match(/^[0-9]{9}[0-9X]$/).nil?
    sum = 0;
    0.upto(9) { |ndx| sum += (isbn[ndx]!= 88 ? isbn[ndx].chr.to_i : 10) * (10-ndx) } # 88 is ascii of X
    sum % 11 == 0
  end
  
  # Check that the value is a valid ISBN-13 number. Returns true if it is, false otherwise.
  # The method will check that the number is exactly 13 digits long and that the thirteenth digit is
  # the correct checksum for the number.
  def is_valid_isbn13?(isbn_)
    isbn = cleanup(isbn_)
    return false if isbn.nil? or isbn.length!=13 or isbn.match(/^97[8|9][0-9]{10}$/).nil?
    sum = 0
    0.upto(12) { |ndx| sum += isbn[ndx].chr.to_i * (ndx % 2 == 0 ? 1 : 3) }
    sum.remainder(10) == 0
  end

  private
  
  # Clear all useless characters from an ISBN number and upcase the 'X' sign when
  # present.  Also does the basic check that 'X' must be the last sign of the number,
  # if present.  Returns nil if provided string is nil or X is not at the last position.
  #
  # No length check is done: no matter what string is passed in, all characters that
  # not in the range [0-9xX] are removed.
  def cleanup(isbn_)
    isbn_.gsub(/[^0-9xX]/,'').gsub(/x/,'X') unless isbn_.nil? or isbn_.scan(/([xX])/).length > 1
  end

  
end
