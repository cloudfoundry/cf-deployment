require 'yaml'
require 'tempfile'
require 'json'
require 'pry'

describe "Manifest Generation" do
  # shared_examples "generating manifests" do |infrastructure|
  #   it "builds the correct manifest for #{infrastructure}" do
  #     example_manifest = Tempfile.new("example-manifest.yml")
  #     `./scripts/generate_deployment_manifest #{infrastructure} spec/fixtures/#{infrastructure}/cf-stub.yml > #{example_manifest.path}`
  #     expect($?.exitstatus).to eq(0)

  #     expected = File.read("spec/fixtures/#{infrastructure}/cf-manifest.yml.erb")
  #     lamb_properties = LambProperties.new(infrastructure)
  #     expected = ERB.new(expected).result(lamb_properties.get_binding)
  #     actual = File.read(example_manifest.path)

  #     expect(actual).to yaml_eq(expected)
  #   end
  # end

  # context "aws" do
  #   # ds
  #   it_behaves_like "generating manifests", ds
  # end

  let(:blessed_versions) { JSON.parse(File.read("blessed_versions.json")) }

  describe 'prepare-deployments' do
    let(:deployments_dir) { Dir.mktmpdir }
    let(:config_file) { Tempfile.new("config.json") }
    let(:config) do
      {
        'deployments-dir' => "#{deployments_dir}"
      }
    end

    before do
      config_file.write(config.to_json)
      config_file.close
    end

    it 'correctly sets the deployments dir' do
      `./tools/prepare-deployments aws #{config_file.path}`

      expect(Dir.entries(deployments_dir)).to include("releases.yml")
    end

    context 'when the deployments dir is not a directory' do
      let(:deployments_dir) { "goobers" }

      it 'requires that the deployments dir exists and is a directory' do
        output = `./tools/prepare-deployments aws #{config_file.path}`

        expect(output).to match(/deployments-dir must be a directory/)
      end
    end

    describe "releases" do
      context "cf-release" do
        context 'with a local release directory' do
          let(:cf_temp_dir) { Dir.mktmpdir }
          let(:expected_release_yaml) do
            {
              'name' => 'cf',
              'version' => 'create',
              'url' => "file://#{cf_temp_dir}"
            }
          end
          let(:config) do
            {
              'cf' => "#{cf_temp_dir}",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'correctly sets the stub' do
            `./tools/prepare-deployments aws #{config_file.path}`

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_cf = get_element_by_name 'cf', release_yaml
            expect(result_cf).to eq(expected_release_yaml)
          end

          context 'when relative path to directory is given' do
            let(:config) do
              {
                'cf' => "~/some_directory",
                'deployments-dir' => "#{deployments_dir}"
              }
            end

            it 'exits with error' do
              result = system("./tools/prepare-deployments aws #{config_file.path}")
              expect(result).to eq(false)
            end

            it 'does not write the output stubs' do
              `./tools/prepare-deployments aws #{config_file.path}`

              expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
            end
          end
        end

        context 'with integration-latest' do
          let(:config) do
            {
              'cf' => "integration-latest",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'clones repo to temp dir and writes path to this dir to manifest' do
            `./tools/prepare-deployments aws #{config_file.path}`

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_cf = get_element_by_name 'cf', release_yaml
            expect(result_cf['name']).to eq('cf')
            expect(result_cf['version']).to eq('create')
            expect(result_cf['path']).to match /file:\/\/.*\/cf-release/
          end
        end

        # TODO: used shared examples with this and integration-latest above
        # context 'when cf-release is empty' do
        #
        # end
      end

      context 'etcd release' do
        context 'with a local release directory' do
          let(:etcd_temp_dir) { Dir.mktmpdir }
          let(:expected_release_yaml) do
            {
              'name' => 'etcd',
              'version' => 'create',
              'url' => "file://#{etcd_temp_dir}"
            }
          end
          let(:config) do
            {
              'cf' => "director-latest",
              'etcd' => etcd_temp_dir,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'correctly sets the stub' do
            `./tools/prepare-deployments aws #{config_file.path}`

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_element_by_name 'etcd', release_yaml
            expect(result_etcd).to eq(expected_release_yaml)
          end

          context 'when relative path to directory is given' do
            let(:config) do
              {
                'cf' => 'director-latest',
                'etcd' => "~/some_directory",
                'deployments-dir' => "#{deployments_dir}"
              }
            end

            it 'exits with error' do
              result = system("./tools/prepare-deployments aws #{config_file.path}")
              expect(result).to eq(false)
            end

            it 'does not write the output stubs' do
              `./tools/prepare-deployments aws #{config_file.path}`

              expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
            end
          end
        end

        context 'when integration-latest is specified' do
          let(:etcd_temp_dir) { Dir.mktmpdir }
          let(:config) do
            {
              'cf' => "director-latest",
              'etcd' => "integration-latest",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_release_yaml) do
            blessed_version=nil
            blessed_url=nil
            blessed_versions['releases'].each { |e|
              if e['etcd']
                blessed_version = e['etcd']['version']
                blessed_url = e['etcd']['url']
              end
            }
            {
              'name' => 'etcd',
              'version' => "#{blessed_version}",
              'url' => "#{blessed_url}"
            }
          end

          it 'clones repo to temp dir and writes path to this dir to manifest' do
            `./tools/prepare-deployments aws #{config_file.path}`
            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_element_by_name 'etcd', release_yaml
            expect(result_etcd).to eq(expected_release_yaml)
          end
        end

        context 'when director-latest is specified' do
          let(:expected_release_yaml) do
            {
              'name' => 'etcd',
              'version' => 'latest',
              'url' => nil,
            }
          end
          let(:config) do
            {
              'cf' => 'director-latest',
              'etcd' => "director-latest",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'correctly sets the stub' do
            `./tools/prepare-deployments aws #{config_file.path}`

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_element_by_name 'etcd', release_yaml
            expect(result_etcd).to eq(expected_release_yaml)
          end
        end

        context 'when a tarball is specified' do
          let(:etcd_temp_dir) { Dir.mktmpdir }
          let(:expected_release_yaml) do
            {
              'name' => 'etcd',
              'version' => '5+goobers.123',
              'url' => "file://#{etcd_temp_dir}/etcd-release.tgz"
            }
          end
          let(:config) do
            {
              'cf' => 'director-latest',
              'etcd' => "#{etcd_temp_dir}/etcd-release.tgz",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          before do
            release_manifest = {'version' => "5+goobers.123"}

            manifest_file = File.new("#{etcd_temp_dir}/release.MF", 'w')
            manifest_file.write(YAML.dump(release_manifest))
            manifest_file.close

            `cd #{etcd_temp_dir} && tar -czf ./etcd-release.tgz ./release.MF`
          end

          it 'correctly sets the stub' do
            `./tools/prepare-deployments aws #{config_file.path}`

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_element_by_name 'etcd', release_yaml
            expect(result_etcd).to eq(expected_release_yaml)
          end
        end
      end
    end
  end
end

def get_element_by_name(name, array)
  releases = array['releases']
  releases.each { |e|
    if e['name'] == name
      return e
    end
  }
end

