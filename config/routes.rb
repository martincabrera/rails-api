Rails.application.routes.draw do

    # It's good to have versioning in place even though there's only one right now :)
    scope module: "v1" ,as: "v1", defaults: { format: :json }, except: [:new, :edit] do
      resources :courses do
        resources :assignments
      end
    end
end
