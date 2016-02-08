#required to be able to iterate through urls
#and create repo for each
define multiple_yumrepos {
  $app_name = inline_template('<%= @title.split("/")[-5] + "_" + @title.split("/")[-1] %>')
  yumrepo { $app_name:
    baseurl => $title,
    descr   => "Repo for ${app_name}"
  }
}

#Adds deb and rpm repos defined in ReleaseQueue to your env
define releasequeue::application ($application_name = $title,
  $version        = undef,
  $username       = undef,
  $api_key        = undef,
  $local_username = undef
  )
{

  if $version == undef {
    fail('Option "version" is mandatory')
  }

  if $username == undef {
    fail('Option "username" is mandatory')
  }

  if $api_key == undef {
    fail('Option "api_key" is mandatory')
  }

  if $local_username == undef {
    fail('Option "local_username" is mandatory')
  }

  $pkg_type =  $::osfamily ? {
    'debian' => 'deb',
    'redhat' => 'rpm',
    default  => nil,
  }

  if $pkg_type == nil {
    fail("$::operatingsystem not supported!")
  }

  $repo = get_app_version_info($application_name, $version, $pkg_type, $::codename, $username, $api_key)
  if $repo != [] {
    if $pkg_type == 'deb' {

      $root_home_directory = $local_username ? {
        'root'  => '/',
        default => '/home'
      }

      netrc::foruser {"netrc_${local_username}":
        root_home_directory           => $root_home_directory,
        user                          => $local_username,
        machine_user_password_triples => ['api.releasequeue.com', $api_key, ''] #using api key as username
      }

      $netrc_path = "${root_home_directory}/${local_username}/.netrc"

      file {'apt_netrc_conf':
        path    => '/etc/apt/apt.conf.d/00_rq_netrc_creds',
        content => "Dir::Etc::netrc \"${netrc_path}\";",
        mode    => '0644',
        owner   => $local_username
      }

      apt::source { $application_name:
        location => $repo["url"],
        repos    => $repo["components_joined"],
      }
    }
    else {
      multiple_yumrepos { $repo['urls']: }
    }
  }
}
