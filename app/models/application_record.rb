class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  before_action :authenticate_user! # Ensures users are logged in
end
