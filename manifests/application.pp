#required to be able to iterate through urls
#and create repo for each
define multiple_yumrepos {
  $app_name = inline_template('<%= @title.split("/")[-5] + "_" + @title.split("/")[-1] %>')
  yumrepo { $app_name:
    baseurl => $title,
    descr => "Repo for $app_name"
  }
}

define releasequeue::application ($application_name = $title,
  $version        = undef,
  $email          = undef,
  $password       = undef,
  $local_username = undef
  )
{

  if $version == undef {
    fail('Option "version" is mandatory')
  }

  if $email == undef {
    fail('Option "email" is mandatory')
  }

  if $password == undef {
    fail('Option "password" is mandatory')
  }

  if $local_username == undef {
    fail('Option "local_username" is mandatory')
  }

  $pkg_type =  $osfamily ? {
    'debian' => 'deb',
    'redhat' => 'rpm',
    default  => nil,
  }

  if $pkg_type == nil {
    fail("${operatingsystem} not supported!")
  }

  $repo = get_app_version_info($application_name, $version, $pkg_type, $::codename, $email, $password)
  if $repo != [] {
    if $pkg_type == 'deb' {

      $root_home_directory = $local_username ? {
        'root'  => '/',
        default => '/home'
      }

      netrc::foruser {"netrc_${local_username}":
        root_home_directory         => $root_home_directory,
        user                        => $local_username,
        machine_user_password_triples => ['api.releasequeue.com', $email, $password]
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
