Facter.add(:jenkins_version) do
  confine :java_default_home do |value|
    !value.nil?
  end

  setcode do
    java = Facter.value(:java_default_home)

    # XXX if $::jenkins::libdir is overridden, this will not work.
    libdir = case Facter.value(:osfamily)
             when 'Debian'
               '/usr/share/jenkins'
             else
               '/usr/lib/jenkins'
             end

    Facter::Util::Resolution.exec("#{java}/bin/java -jar #{libdir}/jenkins.war --version")
  end
end
