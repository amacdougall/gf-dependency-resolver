pry
require "./lib/interpreter"

interpreter = Interpreter.new


interpreter.execute("DEPEND   TELNET TCPIP NETCARD")
interpreter.execute("DEPEND TCPIP NETCARD")
interpreter.execute("DEPEND NETCARD TCPIP")

# TCPIP depends on NETCARD. Ignoring command.

interpreter.execute("DEPEND DNS TCPIP NETCARD")
interpreter.execute("DEPEND  BROWSER   TCPIP  HTML")
interpreter.execute("INSTALL NETCARD")

# Installing NETCARD

interpreter.execute("INSTALL TELNET")

# Installing TCPIP
# Installing TELNET

interpreter.execute("INSTALL foo")

# Installing foo

interpreter.execute("REMOVE NETCARD")

# NETCARD is still needed.

interpreter.execute("INSTALL BROWSER")

   # Installing HTML
   # Installing BROWSER

interpreter.execute("INSTALL DNS")

   # Installing DNS

interpreter.execute("LIST")

   # HTML
   # BROWSER
   # DNS
   # NETCARD
   # foo
   # TCPIP
   # TELNET

interpreter.execute("REMOVE TELNET")

   # Removing TELNET
   
interpreter.execute("REMOVE NETCARD")

   # NETCARD is still needed.

interpreter.execute("REMOVE DNS")

   # Removing DNS

interpreter.execute("REMOVE NETCARD")

   # NETCARD is still needed.

interpreter.execute("INSTALL NETCARD")

   # NETCARD is already installed.
interpreter.execute("REMOVE TCPIP")

   # TCPIP is still needed.
interpreter.execute("REMOVE BROWSER")

   # Removing BROWSER
   # Removing HTML
   # Removing TCPIP
interpreter.execute("REMOVE TCPIP")

   # TCPIP is not installed.
interpreter.execute("LIST")

   # NETCARD
   # foo
interpreter.execute("END")

