# Overrided methods to hook into our framework

$blah = Array.new

alias :oldPuts :puts
def puts (x)
  $blah.push(x)
end

at_exit {$blah.each{ |s| oldPuts s }}
