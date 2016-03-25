SimpleCaptcha.setup do |sc|
  # default: 100x28
  sc.image_size = '120x40'

  # default: 5
  sc.length = 6

  # default: simply_blue
  # possible values:
  # 'embosed_silver',
  # 'simply_red',
  # 'simply_green',
  # 'simply_blue',
  # 'distorted_black',
  # 'all_black',
  # 'charcoal_grey',
  # 'almost_invisible'
  # 'random'
  sc.image_style = 'simply_green'

  # default: low
  # possible values: 'low', 'medium', 'high', 'random'
  sc.distortion = 'medium'
  
  sc.image_magick_path = '/usr/bin' # you can check this from console by running: which convert
  #Este paramentro nao existe sc.tmp_path = '/tmp' # or somewhere in project eg. Rails.root.join('tmp/simple_captcha').to_s, make shure directory exists
end