# == Definition: solr::core
# This definition sets up solr config and data directories for each core
#
# === Parameters
# - The $core to create
#
# === Actions
# - Creates the solr web app directory for the core
# - Copies over the config directory for the file
# - Creates the data directory for the core
#
define solr::core(
  $core_name = $title,
  $conf_file = {
    ensure  => directory,
    recurse => true,
    owner   => $solr::owner,
    group   => $solr::group,
    source  => 'puppet:///modules/solr/conf',
    notify  => Service['solr'],
  },
  $properties = true
) {

  $solr_home  = $solr::solr_home

  file { "${solr_home}/${core_name}":
    ensure  => directory,
    owner   => $solr::owner,
    group   => $solr::group,
    require => File[$solr_home],
  }

  #Copy its config over
  if $conf_file {
    create_resources('file', {"${solr_home}/${core_name}/conf" => $conf_file})
  }
  
  $defaultProperties = {name => $core_name}
  $emptyProperties = {}

  $finalProps = $properties ? { 
    true => $defaultProperties, 
    default => $properties 
  }

  #Copy the jetty config file
  file { "${solr_home}/${core_name}/core.properties":
    ensure  => file,
    content  => template('solr/core.properties.erb'),
    owner   => $solr::owner,
    group   => $solr::group,
    mode    => 0644,
    notify  => Service['solr'],
  }


  # <% @cores.each do |core|  %>
  #   <core name="<%= core -%>" instanceDir="<%= core -%>"
  #         dataDir="/var/lib/solr/<%= core -%>" />
  # <% end if @cores%>


}
