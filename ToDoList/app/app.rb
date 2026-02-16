require 'sinatra'
require 'securerandom'
require_relative 'helpers'

helpers Helpers

enable :sessions
set :session_secret, SecureRandom.hex(64)

USUARIOS = []
TAREAS = []

=begin
  Verifica que al entrar a la raiz de la ruta haya una sesion iniciada y si es que no hay una,
  redirecciona al usuario a /login
=end
get '/' do
  verificar!
  @tareas = TAREAS.select { |t| t[:user_id] == usuario_actual[:id] }
  erb :tasks
end

get '/register' do
  erb :register
end

# Crear nuevos usuarios
post '/register' do
  usuario = params[:username]
  contraseña = params[:password]

  if usuario.strip.empty? || contraseña.strip.empty?
    redirect '/register'
  end

  if USUARIOS.any? { |u| u[:username] == usuario }
    redirect '/register'
  end

  USUARIOS << {
    id: SecureRandom.uuid,
    username: usuario,
    password: contraseña
  }

  redirect '/login'
end

get '/login' do
  redirect '/' if usuario_actual
  erb :login
end

post '/login' do
  user = USUARIOS.find do |u|
    u[:username] == params[:username] && u[:password] == params[:password]
  end

  if user
    session[:user_id] = user[:id]
    redirect '/'
  else
    redirect '/login'
  end
end

get '/logout' do
  session.clear
  redirect '/login'
end

post '/tasks' do
  verificar!

# Crear nuevas tareas
  TAREAS << {
    id: SecureRandom.uuid,
    title: params[:title],
    completed: false,
    user_id: usuario_actual[:id]
  }

  redirect '/'
end

# Marcar como completada o no la tarea
post '/tasks/:id/toggle' do
  verificar!

  tarea = TAREAS.find do |t|
    t[:id] == params[:id] && t[:user_id] == usuario_actual[:id]
  end

  tarea[:completed] = !tarea[:completed] if tarea

  redirect '/'
end


# Eliminar una tarea
post '/tasks/:id/delete' do
  verificar!

  TAREAS.reject! do |t|
    t[:id] == params[:id] && t[:user_id] == usuario_actual[:id]
  end

  redirect '/'
end
