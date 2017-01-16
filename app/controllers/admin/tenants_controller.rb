class Admin::TenantsController < ApplicationController
  layout 'admin'
  skip_before_filter :authenticate_user!
  before_filter :authenticate_admin_user!
  inherit_resources

  # Define a specific ability helper using the admin user
  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

  # Redirect to the called path before the login
  def after_sign_in_path_for(resource)
      (session[:"user.return_to"].nil?) ? "/" : session[:"user.return_to"].to_s
  end

  # Actions
  # =======
  def new
    @tenant = Admin::Tenant.new(params[:admin_tenant])
    @user = User.new(params[:user])
  end

  def create
    @tenant = Admin::Tenant.new(params[:admin_tenant])
    @tenant.db_name = @tenant.subdomain if @tenant.db_name.blank?
    @user = User.new(params[:user])
    @user.role_texts = ['admin']
    @instance_tenant = ::Tenant.new(:admin_tenant => @tenant)
    @user.tenant = @instance_tenant

    @tenant.valid?
    @user.valid?

    if @instance_tenant.valid? && @user.valid? && @tenant.save
      Apartment::Tenant.create(@tenant.db_name)
      Apartment::Tenant.switch(@tenant.db_name) do
        load "#{Rails.root}/db/seeds.rb"

        @instance_tenant.save!
        # Assign roles again, as we need to assign the roles in this db.
        @user.role_texts = ['admin']
        @user.save!
      end

      Apartment::Tenant.reset
      redirect_to @tenant
    else
      render 'new'
    end
  end

  # Resource setup
  protected
    def collection
      instance_eval("@#{controller_name.pluralize} ||= end_of_association_chain.accessible_by(current_ability, :list).paginate(:page => params[:page], :per_page => params[:per_page])")
    end
end
