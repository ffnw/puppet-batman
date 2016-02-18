# puppet-batman

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with batman](#setup)
    * [Beginning with batman](#beginning-with-batman)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Installs and manages B.A.T.M.A.N. Advanced.

## Setup

### Beginning with batman

```puppet
batman::interface { 'bat0':
  interface => [ 'eth0' ],
}
```

## Usage

```puppet
batman::interface { 'bat0':
  interface => [ 'eth0' ],
  gw_mode   => 'server',
  bandwidth => '1000mbit/1000mbit',
}
```

## Reference

* define batman::interface
  * $interfaces (optional, default [])
  * $orig\_interval (optional)
  * $ap\_isolation (optional)
  * $bridge\_loop\_avoidance (optional)
  * $distributed\_arp\_table (optional)
  * $aggregation (optional)
  * $bonding (optional)
  * $fragmentation (optional)
  * $network\_coding (optional)
  * $multicast\_mode (optional)
  * $loglevel (optional)
  * $gw\_mode (optional)
  * $sel\_class (optional)
  * $bandwidth (optional)
  * $routing\_algo (optional)
  * $isolation\_mark (optional)

## Limitations

### OS compatibility
* Debian 8

## Development

### How to contribute
Fork the project, work on it and submit pull requests, please.

