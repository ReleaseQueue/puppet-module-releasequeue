# Releasequeue Puppet Module

## Overview

This module contains a defined type for configuring apt and rpm repositories for your applications defined in Releasequeue so that packages added to your application version should be available for install via apt/yum.

## Setup

### What releasequeue affects

* Will create the apt/yum configurations for installing packages from Releasequeue.

### Setup Requirements **OPTIONAL**

lsb_release is required for mapping between os codename and configuration in Releasequeue.


## Usage
```
releasequeue::application { 'app1':
  version        => '1.0',
  username       => 'your_releasequeue_username',
  api_key        => 'releasequeue_password',
  local_username => 'local_user_on_the_machine', #required for setting up netrc for the Releasequeue connection
}
```
