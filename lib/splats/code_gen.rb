def argsToString (argsList)
  return nil if argsList.nil?
  out = ""
  out << "("
  argsList[0..-2].each{ |a| out << "#{a}," }
  out << "#{argsList[-1]}"
  out << ")"
end

def printLine (line)
  if (line.out.nil?)
    puts "#{line.obj}.#{line.meth}#{argsToString line.args}"
  else
    puts "#{line.out} = #{line.obj}.#{line.meth}#{argsToString line.args}"
  end
end

def printMethod (codeList)
  puts "def #{codeList.hash}"
  codeList[0..-2].each{ |line| printLine line }
  # Assume last line is assert statement
  printAssert(codeList[-1])
  puts "end"
end

def printAssert (line)
  puts "assert_equal #{line.obj}.#{line.meth}#{argsToString line.args}, #{line.out}"
end

# How to turn exceptional output to string
def exceptionToString (ex)
  ex.class.name
end

# Variables to compare against have symbols

# Assume any concrete outputs have to_s method
