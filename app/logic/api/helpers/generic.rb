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
  module Helpers
    module Generic

      # Generic auth process
      def auth(authorization = [], authentication = true)
        authenticate! if authentication
        authorize!(authorization) unless authorization.empty?
      end

      # Generic method for returning of the specific object based on the owner
      def return_many(model, entity = nil, authorization = [], authentication = true)
        auth(authorization, authentication)
        # present
        present_ok(Tools::Class.class_name_to_s(model).pluralize.to_sym, present(model.all, with: entity))
      end

      # Generic method for returning of the specific object based on the owner
      def return_one(model, entity, key, authorization = [], authentication = true)
        return_one_custom(model, entity, key, authorization, authentication) do |object|
          # present
          present_ok(Tools::Class.class_name_to_sym(model), present(object, with: entity, type: :detail))
        end
      end

      def return_one_custom(model, entity, key, authorization = [], authentication = true)
        auth(authorization, authentication)
        # get project
        object = model.find_by(key => params[key])
        # present or not found
        if (object.nil?)
          error_not_found
        else
          # authorize the owner
          authorize!([:author], object) unless authorization.empty?
          # custom action
          yield object if block_given?
        end
      end

      def new_one(model, entity, key, parameters, authorization = [], authentication = true)
        auth(authorization, authentication)
        # get object
        object = model.find_by(key => params[key])
        # present or not found
        if (object.nil?)
          # create new collection
          object = model.new(parameters)
          # object specified code
          yield object if block_given?
          # save
          object.save!
          # present
          present_ok(Tools::Class.class_name_to_sym(model), present(object, with: entity, type: :detail))
        else
          error_already_exists
        end
      end

      def update_one(model, entity, key, authorization = [], authentication = true)
        auth(authorization, authentication)
        # get object
        object = model.find_by(key => params[key])
        # present or not found
        if (object.nil?)
          error_not_found
        else
          # authorize the owner
          authorize!([:author], object) unless authorization.empty?
          # update custom code
          yield object if block_given?
          # save
          object.save!
          # present
          present_ok(Tools::Class.class_name_to_sym(model), present(object, with: entity, type: :detail))
        end
      end

      # Generic method for deleting of the specific object based on the owner
      def delete_one(model, key, authorization = [], authentication = true)
        auth(authorization, authentication)
        # get object
        object = model.find_by(key => params[key])
        # present or not found
        if (object.nil?)
          error_not_found
        else
          # authorize the owner
          authorize!([:author], object) unless authorization.empty?
          # destroy
          object.destroy
          # present
          present_ok
        end
      end
    end
  end
end