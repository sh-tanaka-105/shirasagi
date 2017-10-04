SS::Application.routes.draw do
  Gws::Workflow::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
    post :request_update, on: :member
    post :approve_update, on: :member
    post :remand_update, on: :member
  end

  gws "workflow" do
    get '/' => redirect { |p, req| "#{req.path}/routes" }, as: :setting
    resources :pages, concerns: :deletion
    resources :routes, concerns: :deletion
    resources :files, concerns: :deletion
    resources :forms, concerns: :deletion
    get "/search_approvers" => "search_approvers#index"
    match "/wizard/:id/approver_setting" => "wizard#approver_setting", via: [:get, :post]
    match "/wizard/:id" => "wizard#index", via: [:get, :post]
  end
end
