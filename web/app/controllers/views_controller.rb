# encoding: utf-8

# class ProdutosController < InheritedResources::Base
class ViewsController < ApplicationController
  def serve
    render "../assets/mobile/www/views/#{params[:name]}", layout: nil
  end
end