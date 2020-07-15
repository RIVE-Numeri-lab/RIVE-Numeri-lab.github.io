# https://jekyllrb.com/docs/plugins/filters/

module Jekyll  
  module AssetFilter
    def absolute_urls(input)
      input.gsub! '/assets/', "#{Jekyll.configuration({})['url']}"
    end
  end
end

Liquid::Template.register_filter(Jekyll::AssetFilter)