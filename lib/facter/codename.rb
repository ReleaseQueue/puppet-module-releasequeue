Facter.add(:codename) do
  setcode do
    codename = Facter.value(:lsbdistcodename)
    #if lsb_release is not installed try to get codename ourselves
    if codename.nil? || codename.empty?
      case Facter.value(:osfamily).downcase()
      when "redhat"
        contents = File.read("/etc/redhat-release")
        codename = /\((.*)\)/.match(contents).captures[0]
      when "debian"
        contents = File.read("/etc/os-release")
        codename = /^VERSION=(.*)"$/.match(contents).captures[0]
      end
    end
    codename
  end
end
