require "merci/version"
require "erb"
require "json"
require "net/http"

module Merci
  class Command < Bundler::Plugin::API
    command('merci')

    def exec(_cmd, _args)
      unless Bundler.settings['BUNDLE_MERCI_GITHUB_TOKEN']
        token = Bundler.ui.ask("Please input a valid github token. You can generate a token using this link https://github.com/settings/tokens/new?scopes=public_repo&description=Token%20for%20Bundler%20merci\n")
        Bundler.settings.set_global('BUNDLE_MERCI_GITHUB_TOKEN', token)
      end

      sources = Bundler.definition.specs.each_with_object([]) do |spec, github_sources|
        next unless direct_dependency?(spec) && hosted_on_rubygem?(spec)

        source_code = source_code_uri(spec)
        github_sources << source_code if source_code
      end

      Bundler.ui.info('Starring dependencies your project depends on. Hold tight!')

      repo_ids = execute_graphql_request(graphql_repo_template(sources))
      execute_graphql_request(graphql_add_star_template(repo_ids))

      Bundler.ui.info('Successfully starred all the repo your project depends on!')
    end

    private

    def execute_graphql_request(query)
      @client ||= Net::HTTP.new('api.github.com', Net::HTTP.https_default_port).tap do |client|
        client.use_ssl = true
        client.read_timeout = 30
        client.ssl_timeout = 15
      end

      response = @client.post('/graphql', { query: query }.to_json, "Authorization" => "bearer #{Bundler.settings['BUNDLE_MERCI_GITHUB_TOKEN']}")
      raise(response.body) unless response.code_type < Net::HTTPSuccess

      response.body
    end

    def graphql_add_star_template(repo_ids)
      template = <<~EOM
        mutation StarRepo {
          <% repo_ids.each do |index, values| %>
            <% next unless values && values['id'] %>
            <%= index %>: addStar(input: {clientMutationId: "<%= index %>", starrableId: "<%= values['id'] %>"}) {
              clientMutationId
            }
          <% end %>
        }
      EOM

      repo_ids = JSON.load(repo_ids)['data']
      repo_ids.delete('errors')
      ERB.new(template).result(binding)
    end

    def graphql_repo_template(sources)
      template = <<~EOM
        query FindRepoIds {
          <% sources.each_with_index do |source, index| %>
            <% owner, repo = source.split('/') %>
            _<%= index + 1 %>: repository(owner: "<%= owner %>", name: "<%= repo %>") {
              id
            }
          <% end %>
        }
      EOM

      sources.map! do |source|
        source.to_s.match(/github.com\/([\w\-\.]+)\/([\w\-\.]+)\/?/) { "#{$1}/#{$2}" }
      end

      ERB.new(template).result(binding)
    end

    def direct_dependency?(spec)
      Bundler.locked_gems.dependencies.key?(spec.name)
    end

    def hosted_on_rubygem?(spec)
      return false unless spec.source.is_a?(Bundler::Source::Rubygems)

      spec.source.remotes.any? do |remote|
        remote.respond_to?(:host) && remote.host == 'rubygems.org'
      end
    end

    def source_code_uri(spec)
      homepage = URI(spec.homepage || '')
      return homepage if homepage.host == 'github.com'

      metadata = %w(source_code_uri homepage_uri bug_tracker_uri).find do |key|
        uri = URI(spec.metadata.fetch(key, ''))
        uri.host == 'github.com'
      end

      spec.metadata[metadata] if metadata
    end
  end
end
