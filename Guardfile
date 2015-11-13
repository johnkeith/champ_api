guard :rack do
  watch('Gemfile.lock')
  watch(%r{^app/(.+)\.rb$})
end

guard :rspec, cmd: 'rspec spec' do
  watch(%r{^app/(.+)\.rb$})  { 'spec' }
  watch(%r{^spec/(.+)\.rb$}) { 'spec' }
end