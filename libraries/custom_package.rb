# coding: utf-8
# frozen_string_literal: true
#
# © 2018 Konstantin Gredeskoul (twitter.com/kig)
# https://github.com/kigster

module AutoUpdater
  class CustomPackage < Chef::Resource

    resource_name :auto_updater_custom_package

    property :custom_package, String, name_property: true
    property :package_version, [String, NilClass], default: nil
    property :alt_name, [String, nil], defaukl: nil
    property :package_arch, [String, nil], default: nil
    property :continue_on_error, [TrueClass, FalseClass], default: true

    action :run do
      res = new_resource

      package res.custom_package do
        package_name res.alt_name if res.alt_name
        version res.package_version if res.package_version
        arch res.package_arch if res.package_arch
        ignore_failure res.continue_on_error
      end
    end
  end
end
