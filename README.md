# Publish to OBS action

This action will publish a new revision of the package in OBS.

## Prerequisite

To be able to generate the OBS changelog, you need to have a CHANGELOG file that
follows the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

## Inputs

### `obs user`

**Required** username used to access OBS.

### `obs pass`

**Required**  password used to access OBS.

### `obs email`

**Required** Email to use in the changelog and OBS config.

### `obs project`

**Required** The name of the OBS project.

### `obs package`

**Required** The name of the OBS package.

### `full name`

**Required** The name of the person listed in the changelog and revision.


## Example usage

```yaml
uses: tspmelo/setup-obs@master
with:
  obs user: ${{ secrets.OBS_USERNAME }}
  obs pass: ${{ secrets.OBS_PASSWORD }}
  obs email: 'tmelo@suse.com'
  obs project: 'home:tmelo:sesdev'
  obs package: 'sesdev'
  full name: 'Tiago Melo'
```
