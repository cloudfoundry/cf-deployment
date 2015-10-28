require 'yaml'
require 'tempfile'
require 'json'
require 'pry'
require 'open3'
require 'fileutils'
require 'support/yaml_eq'
require 'pry'

describe 'Manifest Generation' do
  cached_cf_release_path = "#{File.dirname(__FILE__)}/../tmp/cf-release"

  let(:cf_release_path) { cached_cf_release_path }

  let(:std_out) { command_results[0] }
  let(:std_error) { command_results[1] }
  let(:result) { command_results[2] }

  let(:intermediate_dir) { Dir.mktmpdir }
  let(:deployments_dir) { Dir.mktmpdir }
  let(:stub_path) {File.join(File.dirname(__FILE__), "assets", "stub.yml") }
  let(:stubs_paths) { [stub_path] }
  let(:config_file) { Tempfile.new("config.json") }
  let(:config) do
    {
      'cf' => cf_release_path,
      'deployments-dir' => "#{deployments_dir}",
      'stubs' => stubs_paths
    }
  end

  before do
    config_file.write(config.to_json)
    config_file.close
  end

  after(:each) do |example|
    if example.exception
      puts std_out
      puts std_error
    end
  end

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
  end

    #Clean outputs directory
  after(:each) do
    outputs_dir = File.join(File.dirname(__FILE__), "..", "outputs")
    FileUtils.rm_rf(outputs_dir)
  end

  let(:blessed_versions) { JSON.parse(File.read("blessed_versions.json")) }

  describe 'prepare-deployments unit tests'  do

    describe 'validate_num_args' do
      context 'if it has not 2 args' do
        let(:command) { ". ./tools/prepare-deployments && validate_num_args 1" }
        it 'prints an error' do
          expect(result).to_not be_success
          expect(std_error).to include('ERROR: invalid number of arguments provided')
        end
      end

      context 'if it has 2 args' do
        let(:command) { ". ./tools/prepare-deployments && validate_num_args 2" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end
    end

    describe 'validate_infrastructure' do
      context 'when the infrastructure is valid' do
        let(:command) { ". ./tools/prepare-deployments && validate_infrastructure aws" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end

      context 'when the infrastructure is empty' do
        let(:command) { ". ./tools/prepare-deployments && validate_infrastructure ''" }
        it 'prints an error' do
          expect(result).to_not be_success
          expect(std_error).to include "ERROR: infrastructure should not be empty"
        end
      end

      context 'when the infrastructure is invalid' do
        let(:command) { ". ./tools/prepare-deployments && validate_infrastructure banana" }
        it 'prints an error' do
          expect(result).to_not be_success
          expect(std_error).to include("ERROR: invalid infrastructure: banana")
        end
      end
    end

    describe 'validate_config_file_path' do
      context 'when the config file path is valid' do
        let(:command) { ". ./tools/prepare-deployments && validate_config_file_path #{config_file.path}" }
        it 'succeeds' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end

      context 'when the config file path is empty' do
        let(:command) { ". ./tools/prepare-deployments && validate_config_file_path ''" }
        it 'prints an error' do
          expect(result).to_not be_success
          expect(std_error).to include("ERROR: config_file_path should not be empty")
        end
      end

      context 'when the config file path is empty' do
        let(:command) { ". ./tools/prepare-deployments && validate_config_file_path '/banana/path/file.json'" }
        it 'succeeds' do
          expect(result).to_not be_success
          expect(std_error).to include("ERROR: invalid path to config file: /banana/path/file.json")
        end
      end
    end

    describe 'determine_deployments_dir' do
      context 'when the config file contains a deployment-dir field' do
        let(:command) { ". ./tools/prepare-deployments && determine_deployments_dir #{config_file.path} /default/deployments/dir" }
        it 'prints the deployments_dir found from the config file' do
          expect(result).to be_success
          expect(std_out).to include(deployments_dir)
        end
      end

      context 'when the config file does not contain a deployment-dir field' do
        let(:command) { ". ./tools/prepare-deployments && determine_deployments_dir #{config_file.path} /default/deployments/dir" }
        let(:config) do
          {
            'cf' => cf_release_path,
            'stubs' => stubs_paths
          }
        end

        it 'prints the default deployments_dir' do
          expect(result).to be_success
          expect(std_out).to include("/default/deployments/dir")
        end
      end
    end

    describe 'validate_deployments_dir' do
      context 'deployments dir exists' do
        let(:command) { ". ./tools/prepare-deployments && validate_deployments_dir #{deployments_dir}" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end

      context 'deployments dir does not exist' do
        let(:command) { ". ./tools/prepare-deployments && validate_deployments_dir /banana/dir" }
        it 'prints an error' do
          expect(result).to_not be_success
          expect(std_error).to include("deployments-dir must be a directory")
        end
      end
    end

    describe 'determine_release_version' do
      context 'when version is integration-latest for cf-release' do
        let(:command) { ". ./tools/prepare-deployments && determine_release_version integration-latest cf" }

        it 'prints create as a version' do
          expect(result).to be_success
          expect(std_out).to include("create")
        end
      end

      context 'when version is integration-latest not for cf-release' do
        let(:command) { ". ./tools/prepare-deployments && determine_release_version integration-latest etcd" }
        let(:blessed_version) do
          blessed_versions['releases'].each { |release|
            return release['version'] if release['name'] == 'etcd'
          }
        end
        it 'prints version from blessed_versiond' do
          expect(result).to be_success
          expect(std_out).to include(blessed_version)
        end
      end

      context 'when version is director-latest' do
        let(:command) { ". ./tools/prepare-deployments && determine_release_version director-latest etcd" }
        it 'prints latest' do
          expect(result).to be_success
          expect(std_out).to include("latest")
        end
      end

      context 'when version is tarball' do
        let(:release_temp_dir) { Dir.mktmpdir }
        let(:command) { ". ./tools/prepare-deployments && determine_release_version #{release_temp_dir}/release.tgz etcd" }
        before { create_release_tarball_with_manifest(release_temp_dir) }

        it 'look inside tarball.release.MF and peeks a version' do
          expect(result).to be_success
          expect(std_out).to include("5+goobers.123")
        end
      end

      context 'when version is release folder' do
        let(:command) { ". ./tools/prepare-deployments && determine_release_version /tmp/release/dir etcd" }
        it 'prints "create"' do
          expect(result).to be_success
          expect(std_out).to include("create")
        end
      end
    end

    describe 'determine_stemcell_name' do
      context 'when tarball is provided' do
        let(:stemcell_temp_dir) { Dir.mktmpdir }
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_name #{stemcell_temp_dir}/stemcell.tgz" }
        before { create_stemcell_tarball_with_manifest(stemcell_temp_dir) }
        it 'peeks inside tarball and returns a name' do
          expect(result).to be_success
          expect(std_out).to include('yakarandash')
        end
      end

      context 'when tarball is not provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_name not_a_tarball aws" }
        let(:aws_stemcell) { blessed_versions['stemcells']['aws']['type'] }
        it 'gets name from blessed_versions' do
          expect(result).to be_success
          expect(std_out).to include(aws_stemcell)
        end
      end
    end

    describe 'determine_stemcell_version' do
      context 'when tarball is provided' do
        let(:stemcell_temp_dir) { Dir.mktmpdir }
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_version #{stemcell_temp_dir}/stemcell.tgz" }
        before { create_stemcell_tarball_with_manifest(stemcell_temp_dir) }
        it 'peeks inside tarball and gets the version' do
          expect(result).to be_success
          expect(std_out).to include("5+goobers.123")
        end
      end

      context 'when providing "integration-latest"' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_version integration-latest aws" }
        let(:stemcell_version) { blessed_versions['stemcells']['aws']['version'] }
        it 'prints the stemcell version out of the blessed_versions' do
          expect(result).to be_success
          expect(std_out).to include(stemcell_version)
        end
      end

      context 'when providing "director-latest"' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_version director-latest" }
        it 'prints "latest"' do
          expect(result).to be_success
          expect(std_out).to include("latest")
        end
      end
    end

    describe 'determine_stemcell_sha1' do
      context 'when "director-latest" is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_sha1 director-latest" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_out.strip).to be_empty
        end
      end

      context 'when "director-latest" is not provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_sha1 integration-latest aws" }
        let(:stemcell_sha1) { blessed_versions['stemcells']['aws']['sha1'] }
        it 'prints the sha1 from blessed_versions' do
          expect(result).to be_success
          expect(std_out).to include("sha1: \"#{stemcell_sha1}\"")
        end
      end
    end

    describe 'determione_stemcell_location' do
      context 'when "integration-latest" is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_location integration-latest aws" }
        let(:stemcell_location) { blessed_versions['stemcells']['aws']['url'] }
        it 'takes url from blessed_versions' do
          expect(result).to be_success
          expect(std_out).to include("url: \"#{stemcell_location}\"")
        end
      end

      context 'when tarball is provided' do
        let(:stemcell_temp_dir) { Dir.mktmpdir }
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_location #{stemcell_temp_dir}/stemcell.tgz" }
        before { create_stemcell_tarball_with_manifest(stemcell_temp_dir) }
        it 'returns path to this tarball' do
          expect(result).to be_success
          expect(std_out).to include("url: file://#{stemcell_temp_dir}/stemcell.tgz")
        end
      end

      context 'when "director-latest" is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_location director-latest"}
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_out.strip).to be_empty
        end
      end
    end

    describe 'determine_release_location' do
      context 'when "integration-latest" is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_location integration-latest aws" }
        let(:stemcell_url) { blessed_versions['stemcells']['aws']['url'] }
        it 'prints the url from the blessed_versions' do
          expect(result).to be_success
          expect(std_out).to include(stemcell_url)
        end
      end

      context 'when "director-latest" is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_location director-latest" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_out.strip).to be_empty
        end
      end

      context 'when a file path is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stemcell_location /path/to/release/tarball.tgz" }
        it 'prints the path' do
          expect(result).to be_success
          expect(std_out).to include("file:///path/to/release/tarball.tgz")
        end
      end
    end

    describe 'validate_path' do
       context 'when path is not absolute' do
         let(:command) { ". ./tools/prepare-deployments && validate_path path/to/banana" }
         it 'prints an error' do
           expect(result).to_not be_success
           expect(std_error).to include('Path path/to/banana should be absolute.')
         end
       end
       context 'when path does not exist' do
         let(:command) { ". ./tools/prepare-deployments && validate_path /path/to/banana" }
         it 'prints an error' do
           expect(result).to_not be_success
           expect(std_error).to include('File or folder /path/to/banana does not exist')
         end
       end
    end

    describe 'determine_stubs' do
      context 'when stubs are provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stubs #{config_file.path}" }
        let(:config) do
          {
            'cf' => cf_release_path,
            'deployments-dir' => "#{deployments_dir}",
            'stubs' => ["/path/to/stub.yml", "/another/stub.yml"]
          }
        end
        it 'returns stubs' do
          expect(result).to be_success
          expect(std_out).to include("/path/to/stub.yml")
          expect(std_out).to include("/another/stub.yml")
        end
      end

      context 'when stubs are not provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_stubs #{config_file.path}" }
        let(:config) do
          {
            'cf' => cf_release_path,
            'deployments-dir' => "#{deployments_dir}",
          }
        end
        it 'returns stubs' do
          expect(result).to be_success
          expect(std_out.strip).to be_empty
        end
      end
    end

    describe 'validate_stubs' do
      context 'when stubs are not provided' do
        let(:command) { ". ./tools/prepare-deployments && validate_stubs ''" }
        it 'prints an error' do
          expect(result).not_to be_success
          expect(std_error).to include("No stubs provided")
        end
      end

      context 'when stubs are provided' do
        context 'when all stubs have valid paths' do
          let(:command) { ". ./tools/prepare-deployments && validate_stubs '#{stub_path} #{stub_path}'" }
          it 'prints nothing' do
            expect(result).to be_success
            expect(std_out.strip).to be_empty
          end
        end

        context 'when a stub has an invalid path' do
          let(:command) { ". ./tools/prepare-deployments && validate_stubs '#{stub_path} /banana/#{stub_path}'" }
          it 'prints an error' do
            expect(result).not_to be_success
            expect(std_error).to include("File or folder /banana/#{stub_path} does not exist")
          end
        end
      end
    end

    describe 'determine_variant' do
      context 'when no variant is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_variant #{config_file.path} etcd" }
        it 'prints "integration-latest"' do
          expect(result).to be_success
          expect(std_out).to include("integration-latest")
        end
      end

      context 'when empty variant is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_variant #{config_file.path} etcd" }
        let(:config) do
          {
            'etcd' => '',
            'deployments-dir' => "#{deployments_dir}",
            'stubs' => ["/path/to/stub.yml", "/another/stub.yml"]
          }
        end
        it 'prints "integration-latest"' do
          expect(result).to be_success
          expect(std_out).to include("integration-latest")
        end
      end

      context 'when variant is provided' do
        let(:command) { ". ./tools/prepare-deployments && determine_variant #{config_file.path} cf" }
        it 'prints variant value' do
          expect(result).to be_success
          expect(std_out).to include(cf_release_path)
        end
      end
    end

    describe 'validate_etcd_release_variant' do
      context 'when variant is not integration-latest and not director-latest and not a valid path' do
        let(:command) { ". ./tools/prepare-deployments && validate_etcd_release_variant banana" }
        it 'prints error' do
          expect(result).to_not be_success
          expect(std_error).to include('Path banana should be absolute')
        end
      end

      context 'when variant is integration-latest' do
        let(:command) { ". ./tools/prepare-deployments && validate_etcd_release_variant integration-latest" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end

      context 'when variant is director-latest' do
        let(:command) { ". ./tools/prepare-deployments && validate_etcd_release_variant director-latest" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end

      context 'when variant is a valid path' do
        let(:command) { ". ./tools/prepare-deployments && validate_etcd_release_variant #{config_file.path}" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end
    end

    describe 'validate_cf_release_variant' do
      context 'when variant is not integration-latest and not a valid path' do
        let(:command) { ". ./tools/prepare-deployments && validate_cf_release_variant banana" }
        it 'prints error' do
          expect(result).to_not be_success
          expect(std_error).to include('Path banana should be absolute')
        end
      end

      context 'when variant is integration-latest' do
        let(:command) { ". ./tools/prepare-deployments && validate_cf_release_variant integration-latest" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end

      context 'when variant is a valid path' do
        let(:command) { ". ./tools/prepare-deployments && validate_cf_release_variant #{config_file.path}" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end
    end

    describe 'determine_cf_release_location' do
      context 'when variant is not integration-latest' do
        let(:command) { ". ./tools/prepare-deployments && determine_cf_release_location not-integration-latest" }
        it 'returns variant' do
          expect(result).to be_success
          expect(std_out).to include('not-integration-latest')
        end
      end

      context 'when variant is integration-latest', clone: true do
        let(:command) { ". ./tools/prepare-deployments && determine_cf_release_location integration-latest" }
        it 'returns a temp directory that contains cf-release' do
          expect(result).to be_success
          expect(std_out).to include('/cf-release')
        end
      end
    end

    describe 'clone_cf_release', clone: true do
      context 'correct dir and cf_deployment are provided' do
        let(:tmp_dir) {Dir.mktmpdir}
        let(:command) { ". ./tools/prepare-deployments && clone_cf_release #{tmp_dir} ." }
        let(:blessed_commitish) do
          blessed_versions['releases'].each { |release|
            return release['commit'] if release['name'] == 'cf'
          }
        end
        it 'clones repo to dir' do
          expect(result).to be_success
          expect(`cd #{tmp_dir}/cf-release && git show | head -n 1 | cut -d' ' -f2`).to include(blessed_commitish)
        end
      end
    end

    describe 'validate_stemcell_variant' do
      context 'when variant is not integration-latest and not director-latest and not a valid path' do
        let(:command) { ". ./tools/prepare-deployments && validate_stemcell_variant banana" }
        it 'prints error' do
          expect(result).to_not be_success
          expect(std_error).to include('Path banana should be absolute')
        end
      end

      context 'when variant is integration-latest' do
        let(:command) { ". ./tools/prepare-deployments && validate_stemcell_variant integration-latest" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end

      context 'when variant is director-latest' do
        let(:command) { ". ./tools/prepare-deployments && validate_stemcell_variant director-latest" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end

      context 'when variant is a valid path' do
        let(:command) { ". ./tools/prepare-deployments && validate_stemcell_variant #{config_file.path}" }
        it 'prints nothing' do
          expect(result).to be_success
          expect(std_error).to be_empty
        end
      end
    end

    describe 'print_stemcells_stub' do
      context 'everything is provided' do
        let(:command) { ". ./tools/prepare-deployments && print_stemcells_stub banana 1 'url: banana' 'sha1: banana'" }
        it 'prints stemcell stub' do
          expect(result).to be_success
          expect(std_out).to include(<<HEREDOC
---
meta:
  stemcell:
    name: banana
    version: 1
    url: banana
    sha1: banana
HEREDOC
)

        end
      end
    end
    describe 'print_releases_stub' do
      context 'everything is provided' do
        let(:command) { ". ./tools/prepare-deployments && print_releases_stub 1 banana 1 banana" }
        it 'prints stemcell stub' do
          expect(result).to be_success
          expect(std_out).to include(<<HEREDOC
---
releases:
  - name: cf
    version: 1
    url: banana
  - name: etcd
    version: 1
    url: banana
HEREDOC
)
        end
      end

    end
  end

  describe 'prepare-deployments integration tests' do
    let(:command) { ". ./tools/prepare-deployments && main #{File.dirname(__FILE__)} #{infrastructure} #{config_file.path} #{intermediate_dir}" }

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

      let(:command) { ". ./tools/prepare-deployments && main #{File.dirname(__FILE__)} aws #{config_file.path} #{intermediate_dir}" }

      it 'prints an error and exits' do
        expect(result).to_not be_success
        expect(std_error.strip).to include 'not_absolute should be absolute.'
      end
    end

    describe 'releases' do
      describe 'cf-release' do
        context 'with a local release directory' do
          let(:expected_release_yaml) do
            {
              'name' => 'cf',
              'version' => 'create',
              'url' => cf_release_path
            }
          end

          it 'correctly sets the stub' do
            expect(result).to be_success

            release_yaml = YAML.load_file("#{intermediate_dir}/releases.yml")
            result_cf = get_release_by_name 'cf', release_yaml
            expect(result_cf).to eq(expected_release_yaml)
          end

          context 'when relative path to directory is given' do
            let(:cf_release_path) { '~/some_directory' }

            it 'exits with error' do
              expect(result).not_to be_success
              expect(std_error).to include 'should be absolute'
              expect(File.exist?("#{intermediate_dir}/releases.yml")).to eq(false)
            end
          end
        end

        context 'with integration-latest', clone: true do
          let(:config) do
            {
              'cf' => "integration-latest",
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end
          let(:command) { ". ./tools/prepare-deployments && main #{File.dirname(__FILE__)} aws #{config_file.path} #{intermediate_dir}" }

          it 'clones repo to temp dir and writes path to this dir to manifest' do
            expect(result).to be_success

            release_yaml = YAML.load_file("#{intermediate_dir}/releases.yml")
            result_cf = get_release_by_name 'cf', release_yaml
            expect(result_cf['name']).to eq('cf')
            expect(result_cf['version']).to eq('create')
            expect(result_cf['url']).to match /\/.*\/cf-release/
          end
        end

        context 'when cf-release is empty', clone: true do
          let(:command) { ". ./tools/prepare-deployments && main #{File.dirname(__FILE__)} aws #{config_file.path} #{intermediate_dir}" }
          let(:config) do
            {
              'deployments-dir' => "#{deployments_dir}",
              'stubs' => stubs_paths
            }
          end

          it 'clones repo to temp dir and writes path to this dir to manifest' do
            expect(result).to be_success

            release_yaml = YAML.load_file("#{intermediate_dir}/releases.yml")
            result_cf = get_release_by_name 'cf', release_yaml
            expect(result_cf['name']).to eq('cf')
            expect(result_cf['version']).to eq('create')
            expect(result_cf['url']).to match /\/.*\/cf-release/
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
            expect(File.exist?("#{intermediate_dir}/releases.yml")).to eq(false)
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
            expect(File.exist?("#{intermediate_dir}/releases.yml")).to eq(false)
          end
        end
      end

      context 'stemcell' do
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
            stemcell_yaml = YAML.load_file("#{intermediate_dir}/stemcells.yml")
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
            stemcell_yaml = YAML.load_file("#{intermediate_dir}/stemcells.yml")
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
              'url' => "file://#{stemcell_temp_dir}/stemcell.tgz",
              'sha1' => blessed_versions['stemcells'][infrastructure]['sha1']
            }
          end
          let(:config) do
            {
              'cf' => cf_release_path,
              'stemcell' => "#{stemcell_temp_dir}/stemcell.tgz",
              'stubs' => stubs_paths,
              'deployments-dir' => "#{deployments_dir}"
            }
          end

          before do
            create_stemcell_tarball_with_manifest(stemcell_temp_dir)
          end

          it 'correctly sets the stub' do
            expect(result).to be_success

            stemcell_yaml = YAML.load_file("#{intermediate_dir}/stemcells.yml")
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
            expect(File.exist?("#{intermediate_dir}/releases.yml")).to eq(false)
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
            expect(File.exist?("#{intermediate_dir}/releases.yml")).to eq(false)
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
            stemcell_yaml = YAML.load_file("#{intermediate_dir}/stemcells.yml")
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

            release_yaml = YAML.load_file("#{intermediate_dir}/releases.yml")
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
              expect(File.exist?("#{intermediate_dir}/releases.yml")).to eq(false)
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
            release_yaml = YAML.load_file("#{intermediate_dir}/releases.yml")
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

            release_yaml = YAML.load_file("#{intermediate_dir}/releases.yml")
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

            release_yaml = YAML.load_file("#{intermediate_dir}/releases.yml")
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
            expect(File.exist?("#{intermediate_dir}/releases.yml")).to eq(false)
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
            expect(File.exist?("#{intermediate_dir}/releases.yml")).to eq(false)
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
            release_yaml = YAML.load_file("#{intermediate_dir}/releases.yml")
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
          expect(cf_release['url']).to eq(cf_release_path)
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

        it 'writes output to ./outputs/manifests' do
          directory = "#{File.dirname(__FILE__)}/../outputs/manifests"
          FileUtils::mkdir_p directory

          expect(result).to be_success
          deployment_manifest_path = "#{directory}/cf.yml"
          expect(File.exist?(deployment_manifest_path)).to be_truthy
        end
      end

      context 'generate deployment manifest has an error' do
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

def create_stemcell_tarball_with_manifest(dir)
  manifest = {
    'name' => 'yakarandash',
    'version' => "5+goobers.123"
  }

  manifest_file = File.new("#{dir}/stemcell.MF", 'w')
  manifest_file.write(YAML.dump(manifest))
  manifest_file.close

  `cd #{dir} && tar -czf ./stemcell.tgz stemcell.MF`
end

def create_release_tarball_with_manifest(dir)
  manifest = {
    'name' => 'yakarandash',
    'version' => "5+goobers.123"
  }

  manifest_file = File.new("#{dir}/release.MF", 'w')
  manifest_file.write(YAML.dump(manifest))
  manifest_file.close

  `cd #{dir} && tar -czf ./release.tgz ./release.MF`
end
