Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :trackings
  resources :user_trackings, only: :index do
    collection do
      get :image_ad
      get :click_data
      get :event_data
    end
  end  
  # 标签
  namespace :wh_tags do
    resources :page_tags
    resources :base_tags
    resources :pre_tags
  end
  # 标签
  namespace :ad do
    resources :campaigns do
      collection do
        get :event_data_script
        post :save_event_data
        get :get_event_data_script
      end
    end
    resources :creatives
  end

   namespace :cms do
     resources :activities
      resources :activity_details
      resources :articles, except: [:show, :destroy] do
        collection do
          post :upload_image
        end
      end
      resources :jd_tickets, only: [:index] do
        collection do
          get :import_jd_tickets
          post :create_import_jd_tickets
          get :mapping_ticket
          get :jd_activity_details
        end
      end
    end


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
    resources :employees do
      collection do
        get 'forget_password'
        post 'forget_password'
        get 'reset_mail'
        get 'error_mail'
      end
    end
    resources :trackings do
      collection do
        get :analysis
        get :delete_tracking
        get :hot_analysis
        get :vip_tracking
        get :load_detail
      end
    end
    resources :user_trackings, only: :index do
      collection do
        get :analysis
        get :delete_tracking
        get :hot_analysis
        get :analysis_tracking
        get :user_analysis
        get :show_details
        get :get_chart
      end
    end
  end

  root to: 'desboard#index'
  devise_for :employees, path: "admin", path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', sign_up: 'cmon_let_me_in' }, controllers: { sessions: "admin/sessions", passwords: "admin/passwords"}
  match '/admin/ajax_bar' => 'website/ajax_bar/ajax_bar#ajax', :as => :ajax_bar, :via => [:post, :get]

end
