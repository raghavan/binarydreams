require 'rubygems'
require 'sinatra'
require 'rdiscount'

configure :production do
end
not_found do
	erb :not_found
end
get '/' do
  cache_long
  render_topic "home"
end
get '/:topic' + ".html" do
	cache_long
	render_topic params[:topic]
end

helpers do
	def render_topic(topic)
		source = File.read(topic_file(topic))
    @content = markdown(source)
    @title, @content = title(@content)
		# themes available are chat, text, photo, audio, video
    @topic = topic
    @theme = "text"
		erb :topic
	rescue Errno::ENOENT
		status 404
	end
	
  def title(content)
    title = "Yipee, you found something new!"
    unless content.match(/<h1>(.*)<\/h1>/).nil?
      title = content.match(/<h1>(.*)<\/h1>/)[1]
    end
    content_minus_title = content.gsub(/<h1>.*<\/h1>/, '')
    return title, content_minus_title
  end

	def cache_long
		response['Cache-Control'] = "public, max-age=#{60 * 60}" unless development?
	end

	def markdown(source)
		RDiscount.new(notes(source), :smart).to_html
	end
	
	def notes(source)
		source.gsub(/NOTE: (.*)/, '<table class="note"><td class="icon"></td><td class="content">\\1</td></table>')
	end
	

	def topic_file(topic)
		if topic.include?('/')
			topic
		else
			"#{options.root}/articles/#{topic}.markdown"
		end
	end

	def sections
		[
			[ 'ignite_talk_cloning_einstein.html', 'Ignite Talk' ],
			[ 'state_of_theatre_industry_and_evam.html', 'Theatre Industry and Evam' ],
		]
	end

	def next_section(current_slug)
		return sections.first if current_slug.nil?

		sections.each_with_index do |(slug, title), i|
			if current_slug == slug and i < sections.length-1
				return sections[i+1]
			end
		end
		nil
	end

	alias_method :h, :escape_html
end
