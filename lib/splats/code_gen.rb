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
  puts "assert_equal #{codeList[-1].obj}.#{codeList[-1].meth}#{argsToString line.args}, #{codeList[-1].out}"
  puts "end"
end
