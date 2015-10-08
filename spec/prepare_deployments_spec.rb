require 'yaml'
require 'tempfile'
require 'json'
require 'pry'
require 'open3'

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

  cf_release_path = "#{File.dirname(__FILE__)}/../tmp/cf-release"

  let(:std_out) { command_results[0] }
  let(:std_error) { command_results[1] }
  let(:result) { command_results[2] }

  let(:command_results) do
    Open3.capture3(command)
  end

  before(:all) do
    unless Dir.exist?(cf_release_path)
      FileUtils.mkdir_p(cf_release_path)
      `git clone --depth 1 https://github.com/cloudfoundry/cf-release.git #{cf_release_path}`
      `#{cf_release_path}/scripts/update`
    end
  end

  let(:blessed_versions) { JSON.parse(File.read("blessed_versions.json")) }

  describe 'prepare-deployments' do
    let(:deployments_dir) { Dir.mktmpdir }
    let(:config_file) { Tempfile.new("config.json") }
    let(:config) do
      {
        'cf' => cf_release_path,
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
      let(:command) { "./tools/prepare-deployments aws #{config_file.path}" }

      it 'requires that the deployments dir exists and is a directory' do
        expect(result).to_not be_success
        expect(std_error.strip).to eq("deployments-dir must be a directory")
      end
    end

    describe "releases" do
      context "cf-release" do
        context 'with a local release directory' do
          let(:expected_release_yaml) do
            {
              'name' => 'cf',
              'version' => 'create',
              'path' => cf_release_path
            }
          end
          let(:config) do
            {
              'cf' => cf_release_path,
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

        context 'with integration-latest', integration: true do
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
            expect(result_cf['path']).to match /\/.*\/cf-release/
          end
        end

        context 'when cf-release is empty', integration: true do
          let(:config) do
            {
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'clones repo to temp dir and writes path to this dir to manifest' do
            `./tools/prepare-deployments aws #{config_file.path}`

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_cf = get_element_by_name 'cf', release_yaml
            expect(result_cf['name']).to eq('cf')
            expect(result_cf['version']).to eq('create')
            expect(result_cf['path']).to match /\/.*\/cf-release/
          end
        end

        context 'when path is not an absolute path' do
          let(:config) do
            {
              'cf' => "../not_absolute",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints an error and exits' do
            result = system("./tools/prepare-deployments aws #{config_file.path}")
            expect(result).to eq(false)
          end
        end

        context 'when input value is not supported' do
          let(:config) do
            {
              'cf' => 'not_existing_value',
              'etcd' => 'director-latest',
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints error and exits' do
            result = system("./tools/prepare-deployments aws #{config_file.path}")
            expect(result).to eq(false)
          end
        end
      end

      context 'stemcell release' do
        context 'with director-latest' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'stemcell' => "director-latest",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_release_yaml) do
            {
              'name' => 'aws',
              'version' => "latest"
            }
          end

          it 'sets up latest as a version' do
            `./tools/prepare-deployments aws #{config_file.path}`
            stemcell_yaml = YAML.load_file("#{deployments_dir}/stemcell.yml")
            result_stemcell = stemcell_yaml['meta']['stemcell']
            expect(result_stemcell).to eq(expected_release_yaml)
          end
        end

        context 'when integration-latest is specified' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'stemcell' => "integration-latest",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_release_yaml) do
            blessed_version=nil
            blessed_url=nil
            blessed_sha1=nil
            blessed_versions['stemcells'].each { |stemcell|
              if stemcell['name'] == 'aws'
                blessed_version = stemcell['version']
                blessed_url = stemcell['url']
                blessed_sha1 = stemcell['sha1']
              end
            }
            {
              'name' => 'aws',
              'version' => "#{blessed_version}",
              'url' => "#{blessed_url}",
              'sha1' => "#{blessed_sha1}"
            }
          end

          it 'sets up values from blessed version' do
            `./tools/prepare-deployments aws #{config_file.path}`
            stemcell_yaml = YAML.load_file("#{deployments_dir}/stemcell.yml")
            result_stemcell = stemcell_yaml['meta']['stemcell']
            expect(result_stemcell).to eq(expected_release_yaml)
          end
        end

        context 'when tarball is specified' do

          let(:stemcell_temp_dir) { Dir.mktmpdir }
          let(:expected_release_yaml) do
            {
              'name' => 'aws',
              'version' => '5+goobers.123',
              'path' => "file://#{stemcell_temp_dir}/stemcell-release.tgz",
              'sha1' => "b8603fcb27062d3d1af04748d8bb502e1e597afe"
            }
          end
          let(:config) do
            {
              'cf' => cf_release_path,
              'stemcell' => "#{stemcell_temp_dir}/stemcell-release.tgz",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          before do
            release_manifest = {'version' => "5+goobers.123"}

            manifest_file = File.new("#{stemcell_temp_dir}/stemcell.MF", 'w')
            manifest_file.write(YAML.dump(release_manifest))
            manifest_file.close

            `cd #{stemcell_temp_dir} && tar -czf ./stemcell-release.tgz stemcell.MF`
          end

          it 'correctly sets the stub' do
            `./tools/prepare-deployments aws #{config_file.path}`

            stemcell_yaml = YAML.load_file("#{deployments_dir}/stemcell.yml")
            result_stemcell = stemcell_yaml['meta']['stemcell']
            expect(result_stemcell).to eq(expected_release_yaml)
          end
        end

        context 'when path is not an absolute path' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'stemcell' => "../not_absolute",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints an error and exits' do
            result = system("./tools/prepare-deployments aws #{config_file.path}")
            expect(result).to eq(false)
          end
        end

        context 'when input value is not supported' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'etcd' => 'director-latest',
              'stemcell' => 'not_supported',
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints error and exits' do
            result = system("./tools/prepare-deployments aws #{config_file.path}")
            expect(result).to eq(false)
          end
        end

        context 'when no stemcell is specified' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'etcd' => 'director-latest',
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_release_yaml) do
            blessed_version=nil
            blessed_url=nil
            blessed_sha1=nil
            blessed_versions['stemcells'].each { |stemcell|
              if stemcell['name'] == 'aws'
                blessed_version = stemcell['version']
                blessed_url = stemcell['url']
                blessed_sha1 = stemcell['sha1']
              end
            }
            {
              'name' => 'aws',
              'version' => "#{blessed_version}",
              'url' => "#{blessed_url}",
              'sha1' => "#{blessed_sha1}"
            }
          end

          it 'sets up values from blessed version' do
            `./tools/prepare-deployments aws #{config_file.path}`
            stemcell_yaml = YAML.load_file("#{deployments_dir}/stemcell.yml")
            result_stemcell = stemcell_yaml['meta']['stemcell']
            expect(result_stemcell).to eq(expected_release_yaml)
          end
        end
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
              'cf' => cf_release_path,
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
                'cf' => cf_release_path,
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
              'cf' => cf_release_path,
              'etcd' => "integration-latest",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_release_yaml) do
            blessed_version=nil
            blessed_url=nil
            blessed_versions['releases'].each { |release|
              if release['name'] == 'etcd'
                blessed_version = release['version']
                blessed_url = release['url']
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
              'cf' => cf_release_path,
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
              'cf' => cf_release_path,
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

        context 'when path is not an absolute path' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'etcd' => "../not_absolute",
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints an error and exits' do
            result = system("./tools/prepare-deployments aws #{config_file.path}")
            expect(result).to eq(false)
          end
        end

        context 'when input value is not supported' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'etcd' => 'not_supported',
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints error and exits' do
            result = system("./tools/prepare-deployments aws #{config_file.path}")
            expect(result).to eq(false)
          end
        end

        context 'when no value is specified' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_release_yaml) do
            blessed_version=nil
            blessed_url=nil
            blessed_versions['releases'].each { |release|
              if release['name'] == 'etcd'
                blessed_version = release['version']
                blessed_url = release['url']
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
      end
    end

    describe "generating manifest" do
      context 'when one of the stubs is not an absolute path' do
        let(:config) do
          {
            'cf' => cf_release_path,
            'stubs' => [cf_release_path, "not_absolute"],
            'deployments-dir' => "#{deployments_dir}"
          }
        end

        let(:command) { "./tools/prepare-deployments aws #{config_file.path}" }

        it 'prints an error and exits' do
          expect(result).to_not be_success
          expect(std_error.strip).to eq("Stub path not_absolute should be absolute.")
        end
      end

      context 'correct config is provided' do
        let(:config) do
          stubs_pathes = ["#{File.dirname(__FILE__)}/assets/stub.yml"]
          {
            'cf' => cf_release_path,
            'stubs' => stubs_pathes,
            'deployments-dir' => "#{deployments_dir}"
          }
        end

        it 'generates manifest' do
          `./tools/prepare-deployments aws #{config_file.path}`
          expected_release_yaml = YAML.load_file("#{File.dirname(__FILE__)}/fixtures/manifest.yml")
          release_yaml = YAML.load_file("#{deployments_dir}/cf-deployment-manifest.yml")
          expect(release_yaml).to eq(expected_release_yaml)
        end
      end

      context 'no config is provided' do
        let(:expected_etcd_yaml) do
          blessed_version=nil
          blessed_url=nil
          blessed_versions['releases'].each { |release|
            if release['name'] == 'etcd'
              blessed_version = release['version']
              blessed_url = release['url']
            end
          }
          {
            'name' => 'etcd',
            'version' => "#{blessed_version}",
            'url' => "#{blessed_url}"
          }
        end

        let(:expected_stemcell_yaml) do
          blessed_version=nil
          blessed_url=nil
          blessed_sha1=nil
          blessed_versions['stemcells'].each { |stemcell|
            if stemcell['name'] == 'aws'
              blessed_version = stemcell['version']
              blessed_url = stemcell['url']
              blessed_sha1 = stemcell['sha1']
            end
          }
          {
            'name' => 'aws',
            'version' => "#{blessed_version}",
            'url' => "#{blessed_url}",
            'sha1' => "#{blessed_sha1}"
          }
        end

        it 'uses default values' do
          `./tools/prepare-deployments aws`
          release_yaml = YAML.load_file("#{File.dirname(__FILE__)}/../outputs/manifests/releases.yml")

          result_etcd = get_element_by_name 'etcd', release_yaml
          expect(result_etcd).to eq(expected_etcd_yaml)

          cf_yaml = get_element_by_name 'cf', release_yaml
          expect(cf_yaml['name']).to eq('cf')
          expect(cf_yaml['version']).to eq('create')
          expect(cf_yaml['path']).to match /\/.*\/cf-release/

          stemcell_yaml = YAML.load_file("#{File.dirname(__FILE__)}/../outputs/manifests/stemcell.yml")
          result_stemcell = stemcell_yaml['meta']['stemcell']
          expect(result_stemcell).to eq(expected_stemcell_yaml)
        end
      end

      context 'no deployments dir is specified' do
        let(:config) do
          stubs_pathes = ["#{File.dirname(__FILE__)}/assets/stub.yml"]
          {
            'cf' => cf_release_path,
            'stubs' => stubs_pathes
          }
        end

        it 'write output to ./outputs/manifests' do
          `./tools/prepare-deployments aws #{config_file.path}`
          expected_release_yaml = YAML.load_file("#{File.dirname(__FILE__)}/fixtures/manifest.yml")
          release_yaml = YAML.load_file("#{File.dirname(__FILE__)}/../outputs/manifests/cf-deployment-manifest.yml")
          expect(release_yaml).to eq(expected_release_yaml)
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

