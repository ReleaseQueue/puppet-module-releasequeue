require 'serverspec'

describe file('/etc/yum.repos.d/app1_comp1.repo'), :if => ['redhat', 'fedora'].include?(os[:family]) do
  its(:content) { should match /api.releasequeue.com\/users\/admin\/applications\/app1\/1.0\/rpm\/.*\/comp1/ }
end

describe file('/etc/apt/sources.list.d/app1.list'), :if => ['debian', 'ubuntu'].include?(os[:family])  do
  its(:content) { should match /api.releasequeue.com\/users\/admin\/applications\/app1\/1.0\/deb/ }
end

