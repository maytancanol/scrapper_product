require 'test_helper'

class ScrapperProductTest < ActiveSupport::TestCase
  test 'valid url detail product' do
    scrapper_product =  ScrapperProduct.new(root: 'https://magento-test.finology.com.my/lifelong-fitness-iv.html', handler: :process_api)
    result =  scrapper_product.run
    assert result.first['name'] == "LifeLong Fitness IV"
  end
  
  test 'invalid url detail product' do
    scrapper_product =  ScrapperProduct.new(root: 'https://magento-test.finology.com.my', handler: :process_api)
    result =  scrapper_product.run
    assert_empty result
  end

  test 'unique product' do
    product = Product.create("name"=>"LifeLong Fitness IV", "price"=>"14", "description"=>"\n                    \n\n        Luma LifeLong Fitness Series is a world recognized, evidence based exercise program designed specifically for individuals focused on staying active their whole lives. If followed regularly, participants will see improved heart rate and blood pressure, increased mobility, reduced joint pain and overall improvement in functional fitness and health.>\n\n10 minute warm up.\n30 minutes of mild aerobics.\n20 minutes of strength, stretch and balance.\nExtensive modifications for varying fitness levels.\n\n\n                ", "extra_information"=>{"Format"=>"Download", "Activity"=>"Outdoor, Gym, Athletic, Sports"}.map {|h| h.join(':')}.join('|'))
    scrapper_product =  ScrapperProduct.new(root: 'https://magento-test.finology.com.my/lifelong-fitness-iv.html', handler: :process_api)
    scrapper_product.run
    product_count = Product.where(name: "LifeLong Fitness IV").count
    assert product_count == 1
  end
  
end
