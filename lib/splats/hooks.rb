# Overrided methods to hook into our framework

#TODO: More elegant seeming solution in minitest::unit capture_io (line ~290) that redirects stdout/stderr

#TODO: Something to catch SystemExit exceptions being thrown (how exit, Kernel.exit, etc, work)

$stringsPrinted = Array.new

alias :oldPuts :puts
def puts (x)
  $stringsPrinted.push([caller(),x])
end

at_exit {$stringsPrinted.each{ |s| oldPuts "#{s[0][0]}: #{s[1]}" }}
