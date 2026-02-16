module Helpers
    include Rack::Utils
    alias_method :h, :escape_html
  def usuario_actual
    USUARIOS.find { |u| u[:id] == session[:user_id] }
  end

  def verificar!
    redirect '/login' unless usuario_actual
  end
end
