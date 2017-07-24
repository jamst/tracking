Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :trackings

  resources :temporary_reports do
    collection do 
      get :report
      delete :delete_condition
      delete :delete_report
      get :set_report_permission
      get :change_employees
      get :composite_report
      get :chart_report
    end
  end

  namespace :admin do
    resources :users
    resources :employees do
      collection do
        get 'forget_password'
        post 'forget_password'
        get 'reset_mail'
        get 'error_mail'
      end
    end
  end

  root to: 'temporary_reports#index'
  devise_for :employees, path: "admin", path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', sign_up: 'cmon_let_me_in' }, controllers: { sessions: "admin/sessions", passwords: "admin/passwords"}
  match '/admin/ajax_bar' => 'website/ajax_bar/ajax_bar#ajax', :as => :ajax_bar, :via => [:post, :get]

end
