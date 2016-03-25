require "openssl" 
require "net/smtp" 
Net::SMTP.class_eval do
  private
  def do_start(helodomain, user, secret, authtype)
    raise IOError, 'SMTP session already started' if @started
    ########## PROBLEWA DO ERRO (wrong number of arguments (3 for 2))
    no_args = method(:check_auth_args).arity
		if no_args == 2
			check_auth_args user, secret if user or secret
		else
			check_auth_args user, secret, authtype if user or secret
		end
		#check_auth_args user, secret, authtype if user or secret
    ########## PROBLEWA DO ERRO (wrong number of arguments (3 for 2))
    sock = timeout(@open_timeout) { TCPSocket.open(@address, @port) }
    @socket = Net::InternetMessageIO.new(sock)
    @socket.read_timeout = 60 #@read_timeout
    check_response(critical { recv_response() })
    do_helo(helodomain)
    if starttls
      raise 'openssl library not installed' unless defined?(OpenSSL)
      ssl = OpenSSL::SSL::SSLSocket.new(sock)
      ssl.sync_close = true
      ssl.connect
      @socket = Net::InternetMessageIO.new(ssl)
      @socket.read_timeout = 60 #@read_timeout
      do_helo(helodomain)
    end
    authenticate user, secret, authtype if user
    @started = true
  ensure
    unless @started
      # authentication failed, cancel connection.
      @socket.close if not @started and @socket and not @socket.closed?
      @socket = nil
    end
  end
  def do_helo(helodomain)
    begin
      if @esmtp
        ehlo helodomain
      else
        helo helodomain
      end
    rescue Net::ProtocolError
      if @esmtp
        @esmtp = false
        @error_occured = false
        retry
      end
      raise
    end
  end
  def starttls
    getok('STARTTLS') rescue return false
    return true
  end
  def quit
    begin
      getok('QUIT')
    rescue EOFError
    end
  end 
end
