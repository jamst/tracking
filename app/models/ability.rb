class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    cannot :manage, :all
    #send("setup_#{@user.role.name}_access") if @user.present?
  end

end
