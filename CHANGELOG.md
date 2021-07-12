# Changelog

All notable changes to this project will be documented in this file.

## Development

- Added new function `powercli::hosts_status` to retrieve the current connection status
  for ESXi hosts in vCenter.

  Contributed by Nick Maludy (@nmaludy)

## v0.1.2 (2020-11-13)

- Simplified dvs_add_hosts resource. It will no longer take into consideration defaults and other complexities. These complexities are to be handed within the puppet profile which calls this resource.

  Contributed by Greg Perry (@gperry2011)

- Converted from Travis to GitHub Actions

  Contributed by Nick Maludy (@nmaludy)

## v0.1.1 (2020-06-25)

- Fixed idempotency bug in `PSGallery` repository source location.

  Contributed by Nick Maludy (@nmaludy)

## v0.1.0

**Features**

**Bugfixes**

**Known Issues**
