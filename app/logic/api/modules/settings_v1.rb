#
# Copyright (C) 2013 CAS / FAMU
#
# This file is part of Narra Core.
#
# Narra Core is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Narra Core is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Narra Core. If not, see <http://www.gnu.org/licenses/>.
#
# Authors: Michal Mocnak <michal@marigan.net>, Krystof Pesek <krystof.pesek@gmail.com>
#

module API
  module Modules
    class SettingsV1 < Grape::API

      version 'v1', :using => :path
      format :json

      helpers API::Helpers::User

      resource :settings do

        desc "Return settings."
        get do
          authenticate!
          { status: API::Enums::Status::OK, settings: Tools::Settings.all }
        end

        desc "Return defaults."
        get 'defaults' do
          authenticate!
          { status: API::Enums::Status::OK, defaults: Tools::Settings.defaults }
        end

        desc "Return a specific setting."
        get ':name' do
          authenticate!
          # get settings
          setting = Tools::Settings.get(params[:name])
          if (setting.nil?)
            present API::Wrappers::Error.error_not_found, with: API::Entities::Error
          else
            { status: API::Enums::Status::OK, setting: {name: params[:name],  value: setting} }
          end
        end

        desc "Update a specific setting."
        params do
          requires :value, :type => String, :desc => "Setting value."
        end
        get ':name/update' do
          authenticate!
          Tools::Settings.set(params[:name], params[:value]) && { status: API::Enums::Status::OK }
        end
      end
    end
  end
end