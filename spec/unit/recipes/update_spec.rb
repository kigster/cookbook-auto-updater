#
# Cookbook:: auto-updater
# Spec:: default
#
# The MIT License (MIT)
#
# Copyright:: 2018, The Authors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

describe 'auto-updater::update' do
  context 'When all attributes are default, on an Ubuntu 18.04' do

    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '18.04').converge(described_recipe)
    end

    let(:node) { chef_run.node }
    let(:attrs) { node['auto-updater']['update'] }

    it 'should correctly set attributes' do
      expect(attrs['enabled']).to be(true)
      expect(attrs['check_interval_hours']).to eq(24*15)
      expect(attrs['node_check_delay_hours']).to eq(24 * 3)
      expect(attrs['force_update_now']).to be(false)
      expect(attrs['reboot_if_needed']).to be(true)
      expect(attrs['last_update_at']).to be_nil
    end


    it 'should execute the custom resource' do
      expect(chef_run.node['auto-updater']['update']['last_update_at']).to be_nil
      expect(chef_run).to run_auto_updater_update('Automatic Update of Ubuntu Packages and Kernel')
      expect(chef_run.node.normal['auto-updater']['update']['last_update_at']).to_not be_nil
    end

  end

end
