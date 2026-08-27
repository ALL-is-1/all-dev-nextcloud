feature "Change ports" do
	feature "http" do
		after(:all) do
			set_config "ports.http": DEFAULT_HTTP_PORT, "ports.https": DEFAULT_HTTPS_PORT
			wait_for_nextcloud
		end

		scenario "http" do
			set_config "ports.http": 21803
			expect($?.to_i).to eq 0
			wait_for_nextcloud(port: 21803)
			Capybara.app_host = 'http://localhost:21803'

			visit "/"
			assert_uri(https: false, port: 21803)

			# Also assert that we can change it back to the default
			set_config "ports.http": DEFAULT_HTTP_PORT
			expect($?.to_i).to eq 0
			wait_for_nextcloud
			Capybara.app_host = DEFAULT_HTTP_HOST

			visit "/"
			assert_uri(https: false, port: DEFAULT_HTTP_PORT)
		end
	end

	feature "https" do
		before(:all) do
			enable_https
		end

		after(:all) do
			set_config "ports.http": DEFAULT_HTTP_PORT, "ports.https": DEFAULT_HTTPS_PORT
			wait_for_nextcloud
			disable_https
		end

		scenario "https" do
			set_config "ports.https": 15136
			expect($?.to_i).to eq 0
			wait_for_nextcloud(https: true, port: 15136)
			Capybara.app_host = 'https://localhost:15136'

			visit "/"
			assert_uri(https: true, port: 15136)

			# Also assert that we can change it back to the default
			set_config "ports.https": DEFAULT_HTTPS_PORT
			expect($?.to_i).to eq 0
			wait_for_nextcloud(https: true)
			Capybara.app_host = DEFAULT_HTTPS_HOST

			visit "/"
			assert_uri(https: true, port: DEFAULT_HTTPS_PORT)
		end


		scenario "http still redirects to unchanged https" do
			set_config "ports.http": 21803
			expect($?.to_i).to eq 0
			wait_for_nextcloud(port: 21803)
			Capybara.app_host = 'http://localhost:21803'

			visit "/"
			assert_uri(https: true, port: DEFAULT_HTTPS_PORT)
		end


		scenario "http redirects to changed https" do
			set_config "ports.http": 21803, "ports.https": 15136
			expect($?.to_i).to eq 0
			wait_for_nextcloud(port: 21803)
			Capybara.app_host = 'http://localhost:21803'

			visit "/"
			assert_uri(https: true, port: 15136)
		end

		scenario "Let's Encrypt challenge request" do
			# Assert we do not redirect under the four possibilities for
			# changing or not changing ports
			assert_lets_encrypt_challenge(http_port: DEFAULT_HTTP_PORT, https_port: DEFAULT_HTTPS_PORT)
			assert_lets_encrypt_challenge(http_port: DEFAULT_HTTP_PORT, https_port: 15136)
			assert_lets_encrypt_challenge(http_port: 21803, https_port: DEFAULT_HTTPS_PORT)
			assert_lets_encrypt_challenge(http_port: 21803, https_port: 15136)
		end
	end

	protected

	def assert_uri(https:, port:)
		uri = URI.parse(current_url)
		if https
			expect(uri.scheme).to eq 'https'
		else
			expect(uri.scheme).to eq 'http'
		end

		expect(uri.host).to eq 'localhost'
		expect(uri.port).to eq port
	end

	def assert_lets_encrypt_challenge(http_port:, https_port:)
		set_config "ports.http": http_port, "ports.https": https_port
		expect($?.to_i).to eq 0
		wait_for_nextcloud(https: false, port: http_port)
		Capybara.app_host = "http://localhost:#{http_port}"

		visit "/.well-known/acme-challenge/a-challenge-path"
		assert_uri(https: false, port: http_port)
	end
end
