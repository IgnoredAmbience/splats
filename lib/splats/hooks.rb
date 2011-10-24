# Overrided methods to hook into our framework

$stringsPrinted = Array.new

alias :oldPuts :puts
def puts (x)
  $stringsPrinted.push([caller(),x])
end

at_exit {$stringsPrinted.each{ |s| oldPuts "#{s[0][0]}: #{s[1]}" }}
