require 'yaml'
require 'tempfile'
require 'json'
require 'pry'
require 'open3'
require 'support/yaml_eq'

describe 'Manifest Generation' do
  cached_cf_release_path = "#{File.dirname(__FILE__)}/../tmp/cf-release"

  let(:cf_release_path) { cached_cf_release_path }

  let(:std_out) { command_results[0] }
  let(:std_error) { command_results[1] }
  let(:result) { command_results[2] }

  let(:command_results) do
    Open3.capture3(command)
  end

  let(:infrastructure) { 'aws' }

  before(:all) do
    unless Dir.exist?(cached_cf_release_path)
      FileUtils.mkdir_p(cached_cf_release_path)
      `git clone --depth 1 https://github.com/cloudfoundry/cf-release.git #{cached_cf_release_path}`
      `#{cached_cf_release_path}/scripts/update`
    end

    #Clean manifests directory
    FileUtils.remove(Dir.glob("#{File.dirname(__FILE__)}/../outputs/manifests/*"))
  end

  let(:blessed_versions) { JSON.parse(File.read("blessed_versions.json")) }

  describe 'prepare-deployments' do
    let(:deployments_dir) { Dir.mktmpdir }
    let(:stubs_paths) { ["#{File.dirname(__FILE__)}/assets/stub.yml"] }
    let(:config_file) { Tempfile.new("config.json") }
    let(:config) do
      {
        'cf' => cf_release_path,
        'deployments-dir' => "#{deployments_dir}",
        'stubs' => stubs_paths
      }
    end
    let(:command) { "./tools/prepare-deployments #{infrastructure} #{config_file.path}" }

    before do
      config_file.write(config.to_json)
      config_file.close
    end

    describe 'infrastructure validation' do
      context 'infrastructure is not valid' do
        let(:infrastructure) { 'not_valid' }

        it 'returns an error' do
          expect(result).to_not be_success
          expect(std_error).to include('Usage: prepare-deployments <aws|bosh-lite|openstack|vsphere> <path_to_config_file>')
        end
      end

      context 'supports bosh-lite infrastructure' do
        let(:infrastructure) { 'bosh-lite' }

        it 'generates manifest with correct config file' do
          expect(result).to be_success
        end
      end
    end

    context 'when the deployments dir is not a directory' do
      let(:deployments_dir) { "goobers" }

      it 'requires that the deployments dir exists and is a directory' do
        expect(result).to_not be_success
        expect(std_error.strip).to include "deployments-dir must be a directory"
      end
    end

    context 'when no config is provided', integration: true do
      let(:command) { "./tools/prepare-deployments aws" }

      it 'returns an error' do
        expect(result).to_not be_success
        expect(std_error).to include 'invalid number of arguments'
        expect(std_error).to include 'Usage: '
      end
    end

    context 'when no stubs are provided' do
      let(:stubs_paths) { [] }
      it 'fail with stub error' do
        expect(result).to_not be_success
        expect(std_error).to include 'No stubs provided'
      end
    end

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
        expect(std_error.strip).to include 'Stub path not_absolute should be absolute.'
      end
    end

    describe 'releases' do
      describe 'cf-release' do
        context 'with a local release directory' do
          let(:expected_release_yaml) do
            {
              'name' => 'cf',
              'version' => 'create',
              'path' => cf_release_path
            }
          end

          it 'correctly sets the stub' do
            expect(result).to be_success

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_cf = get_release_by_name 'cf', release_yaml
            expect(result_cf).to eq(expected_release_yaml)
          end

          context 'when relative path to directory is given' do
            let(:cf_release_path) { '~/some_directory' }

            it 'exits with error' do
              expect(result).not_to be_success
              expect(std_error).to include 'should be absolute'
              expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
            end
          end
        end

        context 'with integration-latest', integration: true do
          let(:config) do
            {
              'cf' => "integration-latest",
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end
          let(:command) { "./tools/prepare-deployments aws #{config_file.path}" }

          it 'clones repo to temp dir and writes path to this dir to manifest' do
            expect(result).to be_success

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_cf = get_release_by_name 'cf', release_yaml
            expect(result_cf['name']).to eq('cf')
            expect(result_cf['version']).to eq('create')
            expect(result_cf['path']).to match /\/.*\/cf-release/
          end
        end

        context 'when cf-release is empty', integration: true do
          let(:command) { "./tools/prepare-deployments aws #{config_file.path}" }
          let(:config) do
            {
              'deployments-dir' => "#{deployments_dir}",
              'stubs' => stubs_paths
            }
          end

          it 'clones repo to temp dir and writes path to this dir to manifest' do
            expect(result).to be_success

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_cf = get_release_by_name 'cf', release_yaml
            expect(result_cf['name']).to eq('cf')
            expect(result_cf['version']).to eq('create')
            expect(result_cf['path']).to match /\/.*\/cf-release/
          end
        end

        context 'when path is not an absolute path' do
          let(:config) do
            {
              'cf' => "../not_absolute",
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints an error and exits' do
            expect(result).not_to be_success
            expect(std_error).to include 'should be absolute'
            expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
          end
        end

        context 'when input value is not supported' do
          let(:config) do
            {
              'cf' => 'not_existing_value',
              'etcd' => 'director-latest',
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints error and exits' do
            expect(result).not_to be_success
            expect(std_error).to include 'should be absolute'
            expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
          end
        end
      end

      context 'stemcell release' do
        context 'with director-latest' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'stemcell' => "director-latest",
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_release_yaml) do
            {
              'name' => blessed_versions['stemcells']['aws']['type'],
              'version' => "latest"
            }
          end

          it 'sets up latest as a version' do
            expect(result).to be_success
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
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_release_yaml) do
            aws_stemcell = blessed_versions['stemcells']['aws']
            {
              'name' => aws_stemcell['type'],
              'version' => aws_stemcell['version'],
              'url' => aws_stemcell['url'],
              'sha1' => aws_stemcell['sha1']
            }
          end

          it 'sets up values from blessed version' do
            expect(result).to be_success
            stemcell_yaml = YAML.load_file("#{deployments_dir}/stemcell.yml")
            result_stemcell = stemcell_yaml['meta']['stemcell']
            expect(result_stemcell).to eq(expected_release_yaml)
          end
        end

        context 'when tarball is specified' do

          let(:stemcell_temp_dir) { Dir.mktmpdir }
          let(:expected_stemcell_yaml) do
            {
              'name' => 'yakarandash',
              'version' => '5+goobers.123',
              'path' => "file://#{stemcell_temp_dir}/stemcell-release.tgz",
              'sha1' => blessed_versions['stemcells'][infrastructure]['sha1']
            }
          end
          let(:config) do
            {
              'cf' => cf_release_path,
              'stemcell' => "#{stemcell_temp_dir}/stemcell-release.tgz",
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          before do
            release_manifest = {
              'name' => 'yakarandash',
              'version' => "5+goobers.123"
            }

            manifest_file = File.new("#{stemcell_temp_dir}/stemcell.MF", 'w')
            manifest_file.write(YAML.dump(release_manifest))
            manifest_file.close

            `cd #{stemcell_temp_dir} && tar -czf ./stemcell-release.tgz stemcell.MF`
          end

          it 'correctly sets the stub' do
            expect(result).to be_success

            stemcell_yaml = YAML.load_file("#{deployments_dir}/stemcell.yml")
            result_stemcell = stemcell_yaml['meta']['stemcell']
            expect(result_stemcell).to eq(expected_stemcell_yaml)
          end
        end

        context 'when path is not an absolute path' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'stemcell' => "../not_absolute",
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints an error and exits' do
            expect(result).not_to be_success
            expect(std_error).to include 'should be absolute'
            expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
          end
        end

        context 'when input value is not supported' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'etcd' => 'director-latest',
              'stemcell' => 'not_supported',
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints error and exits' do
            expect(result).not_to be_success
            expect(std_error).to include 'should be absolute'
            expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
          end
        end

        context 'when no stemcell is specified' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'etcd' => 'director-latest',
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          let(:expected_stemcell_yaml) do
            {
              'name' => blessed_versions['stemcells'][infrastructure]['type'],
              'version' => blessed_versions['stemcells'][infrastructure]['version'],
              'url' => blessed_versions['stemcells'][infrastructure]['url'],
              'sha1' => blessed_versions['stemcells'][infrastructure]['sha1']
            }
          end

          it 'sets up values from blessed version' do
            expect(result).to be_success
            stemcell_yaml = YAML.load_file("#{deployments_dir}/stemcell.yml")
            result_stemcell = stemcell_yaml['meta']['stemcell']
            expect(result_stemcell).to eq(expected_stemcell_yaml)
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
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'correctly sets the stub' do
            expect(result).to be_success

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_release_by_name 'etcd', release_yaml
            expect(result_etcd).to eq(expected_release_yaml)
          end

          context 'when relative path to directory is given' do
            let(:config) do
              {
                'cf' => cf_release_path,
                'etcd' => "~/some_directory",
                'stubs' => stubs_paths,
                'deployments-dir' => "#{deployments_dir}"
              }
            end

            it 'exits with error' do
              expect(result).not_to be_success
              expect(std_error).to include 'should be absolute'
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
              'stubs' => stubs_paths,
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
            expect(result).to be_success
            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_release_by_name 'etcd', release_yaml
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
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'correctly sets the stub' do
            expect(result).to be_success

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_release_by_name 'etcd', release_yaml
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
              'stubs' => stubs_paths,
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
            expect(result).to be_success

            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_release_by_name 'etcd', release_yaml
            expect(result_etcd).to eq(expected_release_yaml)
          end
        end

        context 'when path is not an absolute path' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'etcd' => "../not_absolute",
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints an error and exits' do
            expect(result).not_to be_success
            expect(std_error).to include 'should be absolute'
            expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
          end
        end

        context 'when input value is not supported' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'etcd' => 'not_supported',
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          it 'prints error and exits' do
            expect(result).not_to be_success
            expect(std_error).to include 'should be absolute'
            expect(File.exist?("#{deployments_dir}/releases.yml")).to eq(false)
          end
        end

        context 'when no value is specified' do
          let(:config) do
            {
              'cf' => cf_release_path,
              'stubs' => stubs_paths,
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
            expect(result).to be_success
            release_yaml = YAML.load_file("#{deployments_dir}/releases.yml")
            result_etcd = get_release_by_name 'etcd', release_yaml
            expect(result_etcd).to eq(expected_release_yaml)
          end
        end
      end
    end

    describe 'generating manifest' do
      context 'correct config is provided' do
        let(:config) do
          stubs_paths = ["#{File.dirname(__FILE__)}/assets/stub.yml"]
          {
            'cf' => cf_release_path,
            'etcd' => 'director-latest',
            'stemcell' => 'director-latest',
            'stubs' => stubs_paths,
            'deployments-dir' => "#{deployments_dir}"
          }
        end

        it 'generates manifest' do
          expect(result).to be_success
          release_yaml = YAML.load_file("#{deployments_dir}/cf.yml")
          etcd_release = get_release_by_name('etcd', release_yaml)
          expect(etcd_release['version']).to eq('latest')
          cf_release = get_release_by_name('cf', release_yaml)
          expect(cf_release['version']).to eq('create')
          expect(cf_release['path']).to eq(cf_release_path)
        end

        it 'includes the job templates stubs' do
          expect(result).to be_success
          release_yaml = YAML.load_file("#{deployments_dir}/cf.yml")
          etcd_job = get_job_by_name('etcd_z1', release_yaml)
          expect(etcd_job['templates'][0]['release']).to eq('etcd')
        end
      end

      context 'no deployments dir is specified' do
        let(:config) do
          stubs_paths = ["#{File.dirname(__FILE__)}/assets/stub.yml"]
          {
            'cf' => cf_release_path,
            'etcd' => 'director-latest',
            'stemcell' => 'director-latest',
            'stubs' => stubs_paths
          }
        end

        it 'write output to ./outputs/manifests' do
          expect(result).to be_success
          deployment_manifest_path = "#{File.dirname(__FILE__)}/../outputs/manifests/cf.yml"
          expect(File.exist?(deployment_manifest_path)).to be_truthy
        end
      end

      context 'generate deployemnt manifest has an error' do
        let(:stubs_paths) { ["#{File.dirname(__FILE__)}/assets/empty_stub.yml"] }

        it 'prints error to stderr' do
          expect(result).to_not be_success
            expect(std_error).to include('unresolved nodes')
        end
      end
    end
  end
end

def get_release_by_name(name, manifest)
  releases = manifest['releases']
  releases.each { |e|
    if e['name'] == name
      return e
    end
  }
end

def get_job_by_name(name, manifest)
  jobs = manifest['jobs']
  jobs.each { |e|
    if e['name'] == name
      return e
    end
  }
end

