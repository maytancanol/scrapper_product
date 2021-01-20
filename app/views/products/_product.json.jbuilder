json.extract! product, :id, :name, :price, :description, :extra_information, :created_at, :updated_at
json.url product_url(product, format: :json)
